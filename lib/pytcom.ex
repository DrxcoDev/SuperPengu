defmodule PytComp do
  def compile_pyt(file) do
    IO.puts("\n\U0001f50c Ejecutando plugins (before)...")

    case detect_pyt(file) do
      nil ->
        IO.puts("\n\u274c Error: Extensi�n de archivo no soportada.")
      pyt ->
        output = Path.rootname(file) <> ".out"

        # Ejecutar el comando Python y redirigir la salida a un archivo
        args = [file]
        {result, status} = System.cmd(pyt, args, stderr_to_stdout: true)

        # Escribir el resultado en el archivo de salida
        File.write(output, result)

        IO.puts(String.trim(result))

        if status == 0 do
          IO.puts("\n\u2705 Compilaci�n exitosa: #{output}")
        else
          IO.puts("\n\u274c Error en la compilaci�n")
        end
    end
  end

  defp detect_pyt(file) do
    case Path.extname(file) do
      ".py" -> "python"
      _ -> nil
    end
  end
end
