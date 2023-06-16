defmodule Medic.Checks.Hex do
  # @related [tests](test/medic/checks/hex_test.exs)
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

  def rebar_path do
    mix_home = mix_home()

    case System.version() |> Version.parse() do
      {:ok, %Version{major: 1, minor: minor}} when minor <= 13 ->
        mix_home
        |> Path.join("rebar")

      {:ok, %Version{major: major, minor: minor}} ->
        mix_home
        |> Path.join("elixir/#{major}-#{minor}/rebar3")
    end
  end

  defp mix_home do
    System.get_env("MIX_HOME", Path.join(System.get_env("HOME"), ".mix"))
  end
end
