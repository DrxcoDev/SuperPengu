defmodule SuperPengu.MixProject do
  use Mix.Project

  def project do
    [
      app: :superpengu,
      version: "0.1.0",
      elixir: "~> 1.14",
      escript: [main_module: SuperPengu], # Definir el módulo principal
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    []
  end
end

