defmodule SuperPengu do
  use Bitwise  # IMPORTANTE: Se añade para usar operadores bitwise
  alias AsmComp  # Añadido para usar el módulo AsmComp
  alias PytComp # Añadido para usar el modulo PytComp

  def main(args) do
    case args do
      ["--cross", arch, file] -> compile(file, arch)
      ["--asm", file] -> generate_asm(file)  # Nueva opción para generar código ensamblador
      ["--c-", "-a", file] -> compile_asm(file)  # Nueva opción para compilar ensamblador
      ["--c", "-py", file] -> compile_pyt(file)
      [file] -> compile(file)
      _ ->
        IO.puts("""
        ❌ Uso incorrecto. Usa:
          ./superpengu archivo.c      # Compila un archivo normal
          ./superpengu --cross x86_64 archivo.c  # Compila en modo cruzado
          ./superpengu --asm archivo.c  # Genera código ensamblador
          ./superpengu --compile-asm archivo.s  # Compila código ensamblador
        """)
    end
  end

  defp compile(file, arch \\ "native") do
    if File.exists?(file) do
      IO.puts("\n🔌 Ejecutando plugins (before)...")
      run_plugins()

      compiler = detect_compiler(file)
      output = Path.rootname(file) <> ".out"

      args = if arch == "native", do: ["-O3", "-march=native", "-o", output, file], else: ["-O3", "-o", output, file]
      {result, status} = System.cmd(compiler, args, stderr_to_stdout: true)

      IO.puts(result)

      if status == 0 do
        IO.puts("\n✅ Compilación exitosa: #{output}")
      else
        IO.puts("\n❌ Error en la compilación")
      end

      IO.puts("\n🔌 Ejecutando plugins (after)...")
      run_plugins()
    else
      IO.puts("\n❌ Error: El archivo #{file} no existe.")
    end
  end

  defp generate_asm(file) do
    if File.exists?(file) do
      IO.puts("\n🔌 Ejecutando plugins (before)...")
      run_plugins()

      compiler = detect_compiler(file)
      output = Path.rootname(file) <> ".s"  # El archivo de ensamblador tendrá la extensión .s

      args = ["-O3", "-S", "-o", output, file]  # Usamos el flag -S para generar ensamblador
      {result, status} = System.cmd(compiler, args, stderr_to_stdout: true)

      IO.puts(result)

      if status == 0 do
        IO.puts("\n✅ Código ensamblador generado: #{output}")
      else
        IO.puts("\n❌ Error generando código ensamblador")
      end

      IO.puts("\n🔌 Ejecutando plugins (after)...")
      run_plugins()
    else
      IO.puts("\n❌ Error: El archivo #{file} no existe.")
    end
  end

  defp compile_asm(file) do
    AsmComp.compile_asm(file)  # Llamamos a la función del módulo AsmComp
  end
  defp compile_pyt(file) do
    PytComp.compile_pyt(file)  # Llamamos a la función del módulo AsmComp
  end

  defp detect_compiler(file) do
    case Path.extname(file) do
      ".c" -> "gcc"
      ".cpp" -> "g++"
      ".lgx" -> "./compilers/lgx_compiler"  # Llamaría a tu compilador de LGX
      _ -> "gcc"
    end
  end

  defp run_plugins() do
    plugins_path = "plugins/"

    if File.exists?(plugins_path) do
      plugins = File.ls!(plugins_path)
      |> Enum.filter(fn file ->
        case File.stat(plugins_path <> file) do
          {:ok, %File.Stat{mode: mode}} -> Bitwise.band(mode, 0o111) != 0
          _ -> false
        end
      end)

      Enum.each(plugins, fn plugin ->
        path = Path.join(plugins_path, plugin)

        if File.exists?(path) do
          IO.puts("🔹 Ejecutando #{plugin}...")
          {result, status} = System.cmd(path, [], stderr_to_stdout: true)

          IO.puts(result)
          if status != 0, do: IO.puts("⚠️ Advertencia: #{plugin} terminó con errores.")
        else
          IO.puts("⚠️ Plugin no encontrado: #{plugin}")
        end
      end)
    else
      IO.puts("⚠️ No se encontró la carpeta de plugins.")
    end
  end
end
