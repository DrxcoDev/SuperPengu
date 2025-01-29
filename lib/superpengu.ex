defmodule SuperPengu do
  def main(args) do
    case args do
      [file] -> 
        compile(file, [])
      ["--cross", target | opts] ->
        compile_cross(target, opts)
      _ ->
        IO.puts("Uso: ./superpengu archivo.c o ./superpengu --cross <target> archivo.c")
    end
  end

  # Compilación normal
  defp compile(file, opts) do
    IO.puts("Compilando archivo: #{file}")  # Mostrar el archivo
    IO.inspect(opts, label: "Opciones")

    if File.exists?(file) do
      extension = Path.extname(file)
      compiler = case extension do
        ".c" -> "gcc"
        ".cpp" -> "g++"
        ".lgx" -> "Pengu"  # Usar Pengu para archivos .lgx
        _ -> nil
      end

      if compiler do
        output = Path.basename(file, Path.extname(file)) <> ".out"
        IO.puts("Usando el compilador: #{compiler}")
        IO.puts("Comando: #{compiler} -O3 -march=native -o #{output} #{file} #{opts}")
        
        # Pasando correctamente los argumentos al compilador
        {result, 0} = System.cmd(compiler, ["-O3", "-march=native", "-o", output] ++ opts ++ [file])
        IO.puts(result)
        IO.puts("Compilación exitosa: #{output}")
      else
        IO.puts("Formato no soportado")
      end
    else
      IO.puts("Error: Archivo no encontrado")
    end
  end

  # Compilación cruzada
  defp compile_cross(target, [file | opts]) do
    IO.puts("Compilando: #{file}")  # Mostrar el archivo

    if File.exists?(file) do
      compiler = get_cross_compiler(target)
      if compiler do
        output = Path.basename(file, Path.extname(file)) <> ".out"
        IO.puts("Usando el compilador cruzado: #{compiler}")
        IO.puts("Comando: #{compiler} -O3 -march=native -o #{output} #{file} #{opts}")
        
        {result, 0} = System.cmd(compiler, ["-O3", "-march=native", "-o", output] ++ opts ++ [file])
        IO.puts(result)
        IO.puts("Compilación cruzada exitosa para #{target}: #{output}")
      else
        IO.puts("Error: Compilador cruzado para #{target} no soportado.")
      end
    else
      IO.puts("Error: El archivo #{file} no existe.")
    end
  end

  # Obtener el compilador cruzado según el target
  defp get_cross_compiler("x86_64"), do: "x86_64-linux-gnu-gcc"
  defp get_cross_compiler("arm"), do: "arm-linux-gnueabi-gcc"
  defp get_cross_compiler(_), do: nil
end 

