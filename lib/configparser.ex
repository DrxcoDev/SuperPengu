defmodule ConfigParser do
  @doc """
  Lee un archivo de configuraci�n y extrae los pares clave-valor.
  """
  def parse_config(file_path) do
    case File.read(file_path) do
      {:ok, content} ->
        config =
          content
          |> String.split("\n")
          |> Enum.filter(&(&1 != ""))
          |> Enum.map(&String.trim/1)
          |> Enum.reduce(%{}, fn line, acc ->
            case Regex.run(~r/^\s*(\w+)\s*=\s*(.+)\s*$/, line) do
              [_, key, value] ->
                Map.put(acc, String.to_atom(key), value)
              _ ->
                acc
            end
          end)

        # Exportar la configuraci�n a un archivo .exs
        export_config(config, "env/usr/exported_config.exs")
        config

      {:error, reason} ->
        IO.puts("Error al leer el archivo: #{reason}")
        %{}
    end
  end

  @doc """
  Exporta la configuraci�n a un archivo .exs.
  """
  def export_config(config, export_path) do
    # Convierte el mapa de configuraci�n a una cadena en formato Elixir
    config_content = inspect(config, pretty: true)

    # Escribe el contenido en el archivo
    File.write(export_path, "config = #{config_content}\n")
    IO.puts("Configuraci�n exportada a #{export_path}")
  end
end

# Uso del m�dulo
file_path = "env/usr/conf/pengu.conf"
config = ConfigParser.parse_config(file_path)

IO.inspect(config, label: "Configuraci�n extra�da")
