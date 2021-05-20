defmodule Medic.Checks.Hex do
  @moduledoc """
  Hex installed locally, and mix deps installed.

  ## Examples

      {Check.Hex, :local_hex?}
      {Check.Hex, :installed?}
  """
  def local_hex_installed? do
    {output, 0} = System.cmd("mix", ["archive"])

    if output =~ "hex-",
      do: :ok,
      else: {:error, "local hex not installed", "mix local.hex --force"}
  end

  def packages_installed? do
    {output, 0} = System.cmd("mix", ["deps"])

    if output =~ "the dependency is not available",
      do: {:error, output, "mix deps.get"},
      else: :ok
  end
end
