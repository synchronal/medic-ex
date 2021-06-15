defmodule GenMedic.MixProject do
  use Mix.Project

  @description """
  Medic project generator.

  Adds necessary Medic support files to a project.
  """
  @scm_url "https://github.com/geometerio/medic"
  @version "0.5.0"

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
      main: "README.md",
      source_ref: "v#{@version}"
    ]
  end

  defp package do
    [
      maintainers: [
        "Geometer LLC"
      ],
      licenses: ["MIT"],
      links: %{"GitHub" => @scm_url},
      files: ~w(lib templates mix.exs README.md)
    ]
  end
end
