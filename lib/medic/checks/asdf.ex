defmodule Medic.Checks.Asdf do
  @moduledoc """
  Doctor checks for the ASDF runtime version manager.

  https://asdf-vm.com/#/

  ## Examples

      {Check.Asdf, :package_installed?, ["postgres"]}
      {Check.Asdf, :plugin_installed?, ["postgres"]}
  """

  alias Medic.Check
  alias Medic.Cmd
  alias Medic.Etc

  @doc """
  Checks that ASDF can resolve a version for the declared plugin.
  """
  @spec package_installed?(binary()) :: Check.check_return_t()
  def package_installed?(package),
    do: Check.command_succeeds?("asdf", ["where", package], remedy: "asdf install #{package}")

  @doc """
  Checks that the configured ASDF plugin is installed.
  """
  @spec plugin_installed?(binary()) :: Check.check_return_t()
  def plugin_installed?(plugin),
    do: Check.in_list?(plugin, plugins(), remedy: "asdf plugin add #{plugin}")

  defp plugins,
    do: Cmd.exec!("asdf", ["plugin", "list"]) |> Etc.split_at_newlines()
end
