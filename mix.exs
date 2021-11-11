defmodule Medic.MixProject do
  use Mix.Project

  @gen_medic_url "https://hex.pm/packages/gen_medic"
  @scm_url "https://github.com/geometerio/medic"
  @version "1.2.2"
  def project do
    [
      app: :medic,
      deps: deps(),
      description: "Checks for setting up development environments",
      dialyzer: dialyzer(),
      docs: docs(),
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      homepage_url: @scm_url,
      name: "Medic",
      package: package(),
      preferred_cli_env: [credo: :test, dialyzer: :test],
      source_url: @scm_url,
      start_permanent: Mix.env() == :prod,
      version: @version
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Medic, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:mix_audit, "~> 0.1", only: [:dev, :test], runtime: false}
    ]
  end

  defp dialyzer do
    [
      plt_add_apps: [:ex_unit, :mix],
      plt_add_deps: :app_tree,
      plt_file: {:no_warn, "priv/plts/#{otp_version()}/dialyzer.plt"}
    ]
  end

  defp docs do
    [
      extras: [
        "guides/overview.md",
        "guides/installation.md"
      ],
      groups_for_modules: docs_module_groups(),
      main: "overview",
      source_ref: "v#{@version}"
    ]
  end

  defp docs_module_groups do
    [
      Commands: [
        Medic.Doctor,
        Medic.Test,
        Medic.Update
      ],
      Checks: [
        Medic.Checks,
        Medic.Checks.Asdf,
        Medic.Checks.Chromedriver,
        Medic.Checks.Direnv,
        Medic.Checks.Hex,
        Medic.Checks.Homebrew,
        Medic.Checks.NPM,
        Medic.Checks.Postgres
      ],
      Util: [
        Medic.Check,
        Medic.Cmd,
        Medic.Etc
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp otp_version do
    Path.join([:code.root_dir(), "releases", :erlang.system_info(:otp_release), "OTP_VERSION"])
    |> File.read!()
    |> String.trim()
  end

  defp package do
    [
      licenses: ["MIT"],
      maintainers: ["Geometer"],
      links: %{"GitHub" => @scm_url, "Generators" => @gen_medic_url}
    ]
  end
end
