defmodule AsmComp do
  def compile_asm(file) do
    if File.exists?(file) do
      {config, _binding} = Code.eval_file("env/usr/exported_config.exs")
      IO.puts("Version de la aplicaci�n: #{config[:version]}")
      IO.puts("\n\U0001f50c Ejecutando plugins (before)...")
      run_plugins()

      assembler = detect_assembler(file)

      if !command_exists?(assembler) do
        IO.puts("\n\u274c Error: El ensamblador '#{assembler}' no est� instalado.")

      end

      output = Path.rootname(file) <> ".bin"
      args = case assembler do
        "nasm" -> ["-fbin", file, "-o", output]
        "as" -> ["-o", "#{Path.rootname(file)}.o", file]
      end

      {result, status} = System.cmd(assembler, args, stderr_to_stdout: true)
      IO.puts(result)

      if status == 0 do
        if assembler == "as" do
          output = Path.rootname(file) <> ".out"
          {link_result, link_status} = System.cmd("ld", ["-o", output, "#{Path.rootname(file)}.o"], stderr_to_stdout: true)
          IO.puts(link_result)
          if link_status != 0, do: IO.puts("\n\u274c Error al enlazar con 'ld'")
        end

        File.chmod(output, 0o755)
        IO.puts("\n\u2705 Compilaci�n exitosa: #{output}")
      else
        IO.puts("\n\u274c Error en la compilaci�n")
      end

      IO.puts("\n\U0001f50c Ejecutando plugins (after)...")
      run_plugins()
    else
      IO.puts("\n\u274c Error: El archivo #{file} no existe.")
    end
  end

  defp detect_assembler(file) do
    case Path.extname(file) do
      ".s" -> "as"
      ".asm" -> "nasm"
      _ -> "as"
    end
  end

  defp command_exists?(cmd) do
    System.find_executable(cmd) != nil
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
