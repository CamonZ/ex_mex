defmodule ExMex.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_mex,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      escript: [main_module: ExMex.CLI],
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :yaml_elixir]
    ]
  end

  defp deps do
    [
      {:poison, "~> 3.1"},
      {:tesla, "~> 0.7.1"},
      {:hackney, "~> 1.9.0"},
      {:yaml_elixir, "~> 1.1"}
    ]
  end
end
