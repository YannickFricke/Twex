defmodule Twex.MixProject do
  use Mix.Project

  def project do
    [
      app: :twex,
      version: "0.0.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps, do: []
end
