defmodule Medic.Checks.Hex do
  @moduledoc """
  Hex installed locally, and mix deps installed.

  ## Examples

      {Check.Hex, :local_hex?}
      {Check.Hex, :installed?}
  """

  @doc """
  Checks that hex is installed locally.
  """
  def local_hex_installed? do
    {output, 0} = System.cmd("mix", ["archive"])

    if output =~ "hex-",
      do: :ok,
      else: {:error, "local hex not installed", "mix local.hex --force"}
  end

  @doc """
  Checks that rebar is installed locally.
  """
  def local_rebar_installed? do
    if File.exists?(rebar_path()),
      do: :ok,
      else: {:error, "local rebar not installed", "mix local.rebar --force"}
  end

  @doc """
  Checks that all Mix dependencies are installed.
  """
  def packages_installed? do
    {output, 0} = System.cmd("mix", ["deps"])

    if output =~ "the dependency is not available",
      do: {:error, output, "mix deps.get"},
      else: :ok
  end

  @doc """
  Checks that all Mix dependencies are installed.
  """
  def packages_compiled? do
    {output, 0} = System.cmd("mix", ["deps"])

    if output =~ "the dependency build is outdated",
      do: {:error, "Hex deps are not compiled", "mix deps.compile"},
      else: :ok
  end

  defp rebar_path do
    {elixir_path, 0} = System.cmd("asdf", ["which", "elixir"])
    {elixir_root, _} = elixir_path |> String.trim() |> Path.split() |> Enum.split(-2)

    elixir_root
    |> Path.join()
    |> Path.join([".mix/rebar"])
  end
end
