defmodule Medic.MixProject do
  use Mix.Project

  @version "0.1.0"
  def project do
    [
      app: :medic,
      deps: deps(),
      dialyzer: dialyzer(),
      docs: docs(),
      elixir: "~> 1.12",
      homepage_url: "https://github.com/geometerio/medic",
      name: "Medic",
      preferred_cli_env: [credo: :test],
      source_url: "https://github.com/geometerio/medic",
      start_permanent: Mix.env() == :prod,
      version: @version
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
    ]
  end

  defp dialyzer do
    [
      plt_add_apps: [:mix],
      plt_add_deps: :app_tree,
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
    ]
  end

  defp docs do
    files = File.ls!("guides") |> Enum.map(&"guides/#{&1}")

    [
      main: "overview",
      extras: files ++ ["README.md"]
    ]
  end
end
