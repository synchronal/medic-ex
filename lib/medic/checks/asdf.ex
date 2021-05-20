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

  def package_installed?(package),
    do: Check.command_succeeds?("asdf", ["where", package], remedy: "asdf install #{package}")

  def plugin_installed?(plugin),
    do: Check.in_list?(plugin, plugins(), remedy: "asdf plugin add #{plugin}")

  defp plugins,
    do: Cmd.exec!("asdf", ["plugin", "list"]) |> Etc.split_at_newlines()
end
