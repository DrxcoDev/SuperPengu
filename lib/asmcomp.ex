defmodule AsmComp do
  def compile_asm(file) do
    if File.exists?(file) do
      IO.puts("\n🔌 Ejecutando plugins (before)...")
      run_plugins()

      assembler = detect_assembler(file)
      output = Path.rootname(file) <> ".out"

      args = ["-o", output, file]  # Usamos el flag -o para generar el archivo ejecutable
      {result, status} = System.cmd(assembler, args, stderr_to_stdout: true)

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

  defp detect_assembler(file) do
    case Path.extname(file) do
      ".s" -> "as"  # Usamos el ensamblador predeterminado
      ".asm" -> "nasm"  # Opción común para archivos .asm
      _ -> "as"  # Si no es un archivo de ensamblador, usamos as por defecto
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
