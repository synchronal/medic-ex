defmodule Medic.Checks.Homebrew do
  @moduledoc """
  Expects a Brewfile to be present, and homebrew packages declared in the
  Brewfile to be up-to-date.

  ## Examples

      {Check.Homebrew, :bundled?}
      {Check.Homebrew, :bundled?, [path_to_file]}
  """

  @doc """
  Expects there to be a Brewfile, and for all the dependencies in that Brewfile
  to be up to date.
  """
  @spec bundled?() :: Medic.Check.check_return_t()
  @spec bundled?(Path.t()) :: Medic.Check.check_return_t()
  def bundled? do
    with :ok <- homebrew_installed?(),
         :ok <- brewfile_exists?() do
      case System.cmd("brew", ["bundle", "check"], env: [{"HOMEBREW_NO_AUTO_UPDATE", "1"}]) do
        {_output, 0} -> :ok
        {output, _} -> {:error, output, "brew bundle"}
      end
    end
  end

  def bundled?(file) do
    filepath = Path.expand(file)

    with :ok <- homebrew_installed?(),
         :ok <- brewfile_exists?() do
      case System.cmd("brew", ["bundle", "check", "--file", filepath], env: [{"HOMEBREW_NO_AUTO_UPDATE", "1"}, {"HOME", System.fetch_env!("HOME")}]) do
        {_output, 0} -> :ok
        {output, _} -> {:error, output, "brew bundle --file #{filepath}"}
      end
    end
  end

  @spec brewfile_exists?() :: Medic.Check.check_return_t()
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
