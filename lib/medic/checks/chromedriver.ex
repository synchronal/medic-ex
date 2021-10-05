defmodule Medic.Checks.Chromedriver do
  @moduledoc """
  Checks to see if Chromedriver is allowed to run in the MacOS quarantine sandbox.

  ## Examples

      {Check.Chromedriver, :unquarantined?}
      {Check.Chromedriver, :versions_match?}
  """

  alias Medic.Etc

  @doc """
  Checks to make sure that Google Chrome is installed.
  """
  @spec chrome_installed?() :: Medic.Check.check_return_t()
  def chrome_installed? do
    if File.dir?("/Applications/Google Chrome.app") do
      :ok
    else
      {:error, "Chrome not installed", "brew install --cask google-chrome"}
    end
  end

  @doc """
  Checks that chromedriver is installed, and has not been quarantined by the
  MacOS security sandbox.
  """
  @spec unquarantined?() :: Medic.Check.check_return_t()
  def unquarantined? do
    with {:ok, path} <- chromedriver_path(),
         {:ok, attrs} <- xattrs(path),
         :ok <- quarantine_state(attrs) do
      :ok
    else
      error -> error
    end
  end

  @doc """
  Checks that chromedriver matches the installed version of Chrome.
  """
  @spec versions_match?() :: Medic.Check.check_return_t()
  def versions_match? do
    with {:ok, chromedriver_path} <- chromedriver_path(),
         chromedriver <- Etc.application_version(chromedriver_path, "-v"),
         chrome <- Etc.application_version("/Applications/Google Chrome.app/Contents/MacOS/Google Chrome", "--version") do
      if chromedriver == chrome,
        do: :ok,
        else:
          {:error, "Chrome and Chromedriver version are mismatched",
           """

           # Please make sure the installed ChromeDriver version matches your Chrome browser's version.
           # (Wallaby often fails with 'invalid session id' if the versions differ.)
           # Chromedriver : #{chromedriver}
           # Chrome       : #{chrome}
           """}
    end
  end

  defp chromedriver_path do
    System.cmd("command", ["-v", "chromedriver"])
    |> case do
      {path, 0} -> {:ok, String.trim(path)}
      {output, _} -> {:error, "chromedriver was not found\n#{output}", "brew install --cask chromedriver-beta"}
    end
  end

  defp xattrs(path) do
    System.cmd("xattr", [path])
    |> case do
      {output, 0} -> {:ok, output}
      {output, _} -> {:error, "unable to find chromedriver xattrs\n#{output}", "# are you on a mac?"}
    end
  end

  defp quarantine_state(attrs) do
    if String.contains?(attrs, "com.apple.quarantine"),
      do: {:error, "chromedriver is quarantined by the MacOS security sandbox", "xattr -d com.apple.quarantine $(command -v chromedriver)"},
      else: :ok
  end
end
