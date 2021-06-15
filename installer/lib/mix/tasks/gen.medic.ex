defmodule Mix.Tasks.Gen.Medic do
  @shortdoc "Adds Medic to a project"

  @moduledoc """
  Adds Medic to a project.

  Run `mix gen.medic` in the root path of a project to create a `.medic` directory with
  necessary support files and a `bin/dev` directory with shell scripts.

  ## Options

    * `-v`, `--version` - prints the GenMedic version
  """

  use Mix.Task
  alias GenMedic.Install
  alias GenMedic.Project

  @version Mix.Project.config()[:version]

  @impl true
  def run([option]) when option in ~w(-v --version) do
    Mix.shell().info("GenMedic version v#{@version}")
  end

  def run(_argv) do
    elixir_version_check!()

    File.cwd!()
    |> Project.new()
    |> Project.put_bindings(version: @version)
    |> Install.generate()
  end

  defp elixir_version_check! do
    if Version.compare(System.version(), "1.12.0") == :lt do
      Mix.raise(
        "Medic v#{@version} requires at least Elixir v1.12.\n " <>
          "You have #{System.version()}. Please update accordingly"
      )
    end
  end
end
