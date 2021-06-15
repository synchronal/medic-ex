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
    if brewfile_exists?() == :ok do
      case System.cmd("brew", ["bundle", "check"], env: [{"HOMEBREW_NO_AUTO_UPDATE", "1"}]) do
        {_output, 0} -> :ok
        {output, _} -> {:error, output, "brew bundle"}
      end
    else
      {:error, "Brewfile does not exist", "touch Brewfile"}
    end
  end

  def brewfile_exists? do
    if File.exists?("Brewfile"),
      do: :ok,
      else: {:error, :noent}
  end
end
