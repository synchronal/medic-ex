defmodule Medic.Checks.Homebrew do
  @moduledoc """
  Expects a Brewfile to be present, and homebrew packages declared in the
  Brewfile to be up-to-date.

  ## Examples

      {Check.Homebrew, :bundled?}
  """

  @doc """
  Expects there to be a Brewfile, and for all the dependencies in that Brewfile
  to be up to date.
  """
  def bundled? do
    with :ok <- homebrew_installed?(),
         :ok <- brewfile_exists?() do
      case System.cmd("brew", ["bundle", "check"], env: [{"HOMEBREW_NO_AUTO_UPDATE", "1"}]) do
        {_output, 0} -> :ok
        {output, _} -> {:error, output, "brew bundle"}
      end
    end
  end

  def brewfile_exists? do
    if File.exists?("Brewfile"),
      do: :ok,
      else: {:error, "Brewfile does not exist", "touch Brewfile"}
  end

  def homebrew_installed? do
    case System.cmd("which", ["brew"]) do
      {_output, 0} -> :ok
      {_output, _exit_status} -> {:error, "Homebrew not installed", "open https://brew.sh"}
    end
  end
end
