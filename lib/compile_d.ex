defmodule DComp do
  def compile_d(file) do
    if File.exists?(file) do
      {config, _binding} = Code.eval_file("env/usr/exported_config.exs")
      IO.puts("Versi�n de la aplicaci�n: #{config[:version]}")
      IO.puts("\n\U0001f50c Ejecutando plugins (before)...")
      run_plugins()

      compiler = detect_compiler(file)

      if !command_exists?(compiler) do
        IO.puts("\n\u274c Error: El compilador '#{compiler}' no est� instalado.")
      end

      output = Path.rootname(file) <> ".out"
      args = case compiler do
        "dmd" -> [file, "-of" <> output]
        "ldc2" -> [file, "-of" <> output]
        _ -> []
      end

      {result, status} = System.cmd(compiler, args, stderr_to_stdout: true)
      IO.puts(result)

      if status == 0 do
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

  defp detect_compiler(file) do
    case Path.extname(file) do
      ".d" -> "dmd"  # Usando DMD como compilador de D
      _ -> ""
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
