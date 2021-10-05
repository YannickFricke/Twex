defmodule Twex.MixProject do
  use Mix.Project

  def project do
    [
      app: :twex,
      version: "0.0.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "Twex",
      source_url: "https://github.com/YannickFricke/Twex",
      homepage_url: "https://github.com/YannickFricke/Twex",
      docs: [
        # The main page in the docs
        main: "Twex",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Twex.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:type_check, "~> 0.5.0"}
    ]
  end
end
