defmodule SuperPengu do
  use Bitwise
  alias AsmComp
  alias PytComp
  alias FixNasmSyntax
  alias DComp

  def main(args) do
    IO.puts("SuperPengu [UE] ")
    {verbose, cleaned_args} = extract_verbose(args)

    if verbose do
      IO.puts("Verbose activado")
    end

    case cleaned_args do
      ["--cross", arch, file] -> compile(file, arch, verbose)
      ["--asm", file] -> generate_asm([file])
      ["--c-", "-a", file] -> compile_asm(file)
      ["--c", "-py", file] -> compile_pyt(file)
      ["--c", "-d", file] -> compile_d(file)
      [file] -> compile(file, "native", verbose)
      _ ->
        IO.puts("""
        \u274c Uso incorrecto. Usa:
          ./superpengu archivo.c                 # Compila un archivo normal
          ./superpengu --cross x86_64 archivo.c  # Compila en modo cruzado
          ./superpengu --asm archivo.c           # Genera c�digo ensamblador
          ./superpengu --c- -a archivo.s         # Compila c�digo ensamblador
          ./superpengu --c -py archivo.py        # Compila c�digo Python
        """)
    end
  end

  defp extract_verbose(args) do
    verbose = "--verbose" in args
    {verbose, List.delete(args, "--verbose")}
  end

  defp compile(file, arch \\ "native", verbose \\ false) do
    if File.exists?(file) do
      {config, _binding} = Code.eval_file("env/usr/exported_config.exs")
      IO.puts("Versi�n de la aplicaci�n: #{config[:version]}")
      IO.puts("\n\U0001f50c Ejecutando plugins (before)...")
      run_plugins()

      compiler = detect_compiler(file)
      output = Path.rootname(file) <> ".bin"

      args =
        case arch do
          "native" -> ["-O3", "-march=native", "-o", output, file]
          "x86_64" -> ["-O3", "-target", "x86_64-linux-gnu", "-o", output, file]
          "arm64" -> ["-O3", "-target", "aarch64-linux-gnu", "-o", output, file]
          "riscv64" -> ["-O3", "-target", "riscv64-linux-gnu", "-o", output, file]
          _ -> ["-O3", "-o", output, file]
        end

      if verbose do
        IO.puts("Compilador detectado: #{compiler}")
        IO.puts("Iniciando: #{compiler} #{Enum.join(args, " ")}")
      end

      {result, status} = System.cmd(compiler, args, stderr_to_stdout: true)

      IO.puts(result)

      if status == 0 do
        IO.puts("\n\u2705 Compilaci�n exitosa: #{output}")
      else
        IO.puts("\n\u274c Error en la compilaci�n")
      end

      if verbose, do: IO.puts("\n\U0001f50c Ejecutando plugins (after)...")
      run_plugins()
    else
      IO.puts("\n\u274c Error: El archivo #{file} no existe.")
    end
  end

  defp generate_asm(files) do
    files
    |> Stream.filter(&File.exists?/1)
    |> Stream.each(fn file ->
      {config, _binding} = Code.eval_file("env/usr/exported_config.exs")
      IO.puts("Versi�n de la aplicaci�n: #{config[:version]}")
      IO.puts("\n\U0001f50c Ejecutando plugins (before)...")
      run_plugins()

      case Path.extname(file) do
        ".py" ->
          python_to_c(file)
          file = Path.rootname(file) <> ".c"
        _ -> :ok
      end

      compiler = detect_compiler(file)
      output = Path.rootname(file) <> ".s"

      args = ["-O3", "-S", "-o", output, "-target", "x86_64-none-linux-gnu", "-Xclang", "-std=c11", file]
      {result, status} = System.cmd(compiler, args, stderr_to_stdout: true)

      IO.puts(result)

      if status == 0 do
        IO.puts("\n\u2705 C�digo ensamblador generado: #{output}")
      else
        IO.puts("\n\u274c Error generando c�digo ensamblador")
      end

      IO.puts("\n\U0001f50c Ejecutando plugins (after)...")
      run_plugins()
    end)
    |> Stream.run()
  end

  defp python_to_c(file) do
    IO.puts("\n\U0001f527 Convirtiendo archivo Python a C...")

    output_c = Path.rootname(file) <> ".c"
    {result, status} = System.cmd("cython", ["--embed", "-o", output_c, file], stderr_to_stdout: true)

    if status == 0 do
      IO.puts("\n\u2705 Archivo Python convertido a C exitosamente.")
    else
      IO.puts("\n\u274c Error al convertir el archivo Python a C.")
      IO.puts(result)
    end
  end

  defp compile_asm(file) do
    AsmComp.compile_asm(file)
  end

  defp compile_pyt(file) do
    PytComp.compile_pyt(file)
  end

  defp compile_d(file) do
    DComp.compile_d(file)
  end

  defp detect_compiler(file) do
    compilers = ["clang", "gcc", "g++", "nasm"]

    case Enum.find(compilers, &System.find_executable/1) do
      nil -> raise "No se encontr� un compilador v�lido"
      compiler -> compiler
    end
  end

  defp run_plugins() do
    plugins_path = "plugins/"

    if File.exists?(plugins_path) do
      plugins = File.ls!(plugins_path)
      |> Enum.filter(fn file ->
        case File.stat(Path.join(plugins_path, file)) do
          {:ok, %File.Stat{mode: mode}} -> Bitwise.band(mode, 0o111) != 0
          _ -> false
        end
      end)

      Enum.each(plugins, fn plugin ->
        path = Path.join(plugins_path, plugin)

        if File.exists?(path) do
          IO.puts("\U0001f539 Ejecutando #{plugin}...")
          {result, status} = System.cmd(path, [], stderr_to_stdout: true)

          IO.puts(result)
          if status != 0, do: IO.puts("\u26a0\ufe0f Advertencia: #{plugin} termin� con errores.")
        else
          IO.puts("\u26a0\ufe0f Plugin no encontrado: #{plugin}")
        end
      end)
    else
      IO.puts("\u26a0\ufe0f No se encontr� la carpeta de plugins.")
    end
  end
end
