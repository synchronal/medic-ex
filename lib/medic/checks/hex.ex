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
  @spec local_hex_installed?() :: Medic.Check.check_return_t()
  def local_hex_installed? do
    {output, 0} = System.cmd("mix", ["archive"])

    if output =~ "hex-",
      do: :ok,
      else: {:error, "local hex not installed", "mix local.hex --force"}
  end

  @doc """
  Checks that rebar is installed locally.
  """
  @spec local_rebar_installed?() :: Medic.Check.check_return_t()
  def local_rebar_installed? do
    if File.exists?(rebar_path()),
      do: :ok,
      else: {:error, "local rebar not installed", "mix local.rebar --force"}
  end

  @doc """
  Checks that all Mix dependencies are compiled.

  ## Examples

      {Medic.Checks.Hex, :packages_compiled?}
      {Medic.Checks.Hex, :packages_compiled?, [cd: "subdirectory"]}

  """
  @spec packages_compiled?(opts :: Keyword.t()) :: Medic.Check.check_return_t()
  def packages_compiled?(opts \\ []) do
    case Keyword.fetch(opts, :cd) do
      {:ok, directory} ->
        {output, 0} = System.cmd("mix", ["deps"], cd: directory)

        if output =~ "the dependency build is outdated",
          do: {:error, "Hex deps are not compiled", "(cd #{directory} && mix deps.compile)"},
          else: :ok

      :error ->
        {output, 0} = System.cmd("mix", ["deps"])

        if output =~ "the dependency build is outdated",
          do: {:error, "Hex deps are not compiled", "mix deps.compile"},
          else: :ok
    end
  end

  @doc """
  Checks that all Mix dependencies are installed.

  ## Examples

      {Medic.Checks.Hex, :packages_installed?}
      {Medic.Checks.Hex, :packages_installed?, [cd: "subdirectory"]}

  """
  @spec packages_installed?(opts :: Keyword.t()) :: Medic.Check.check_return_t()
  def packages_installed?(opts \\ []) do
    case Keyword.fetch(opts, :cd) do
      {:ok, directory} ->
        {output, 0} = System.cmd("mix", ["deps"], cd: directory)

        if out_of_date?(output),
          do: {:error, output, "(cd #{directory} && mix deps.get)"},
          else: :ok

      :error ->
        {output, 0} = System.cmd("mix", ["deps"])

        if output =~ "the dependency is not available",
          do: {:error, output, "mix deps.get"},
          else: :ok
    end
  end

  defp out_of_date?(deps_output) do
    cond do
      deps_output =~ "dependency is not available" -> true
      deps_output =~ "dependency is out of date" -> true
      true -> false
    end
  end

  defp rebar_path do
    {elixir_path, 0} = System.cmd("asdf", ["which", "elixir"])
    {elixir_root, _} = elixir_path |> String.trim() |> Path.split() |> Enum.split(-2)

    elixir_root
    |> Path.join()
    |> Path.join([".mix/rebar"])
  end
end
