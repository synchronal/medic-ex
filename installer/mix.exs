defmodule GenMedic.MixProject do
  use Mix.Project

  @description """
  Medic project generator.

  Adds necessary Medic support files to a project.

  ## Installation

  mix archive.install hex gen_medic

  ## Usage

  mix gen.medic
  """
  @medic_url "https://hex.pm/packages/medic"
  @scm_url "https://github.com/geometerio/medic"
  @version "1.5.1"

  def project do
    [
      app: :gen_medic,
      deps: deps(),
      docs: docs(),
      description: @description,
      elixir: "~> 1.12",
      homepage_url: @scm_url,
      package: package(),
      preferred_cli_env: [docs: :dev],
      source_url: @scm_url,
      start_permanent: Mix.env() == :prod,
      version: @version
    ]
  end

  def application do
    [
      extra_applications: [:eex, :logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      extras: [
        "README.md"
      ],
      main: "readme",
      source_ref: "v#{@version}"
    ]
  end

  defp package do
    [
      maintainers: [
        "Geometer LLC"
      ],
      licenses: ["MIT"],
      links: %{"GitHub" => @scm_url, "Medic" => @medic_url},
      files: ~w(lib templates mix.exs README.md)
    ]
  end
end
