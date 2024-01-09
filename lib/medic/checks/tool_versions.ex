defmodule Medic.Checks.ToolVersions do
  @moduledoc """
  Doctor checks for runtime version managers. Prefers [mise-en-place](https://mise.jdx.dev),
  then [asdf](https://asdf-vm.com/#/).

  ## Examples

      {Check.ToolVersions, :package_installed?, ["postgres"]}
      {Check.ToolVersions, :plugin_installed?, ["postgres"]}
  """

  alias Medic.Check
  alias Medic.Support.RuntimeVersionManager, as: Rvm

  @doc """
  Checks that ASDF can resolve a version for the declared plugin.
  """
  @spec package_installed?(binary()) :: Check.check_return_t()
  def package_installed?(package) do
    case Rvm.version_manager() do
      {:ok, rvm} ->
        Check.command_succeeds?(rvm, ["where", package], remedy: "#{rvm} install #{package}")

      {:error, error} ->
        {:error, error, "# Install mise-en-place: https://mise.jdx.dev; or asdf: https://asdf-vm.com"}
    end
  end

  @doc """
  Checks that the configured ASDF plugin is installed.
  """
  @spec plugin_installed?(binary()) :: Check.check_return_t()
  def plugin_installed?(plugin) do
    with {:ok, rvm} <- Rvm.version_manager(),
         {:ok, plugins} <- Rvm.plugins() do
      Check.in_list?(plugin, plugins, remedy: "#{rvm} plugin add #{plugin}")
    else
      {:error, error} ->
        {:error, error, "# Install mise-en-place: https://mise.jdx.dev; or asdf: https://asdf-vm.com"}
    end
  end
end
