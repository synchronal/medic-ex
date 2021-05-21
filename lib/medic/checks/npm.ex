defmodule Medic.Checks.NPM do
  @moduledoc """
  Checks that NPM exists, implicitly checking for NodeJS.

  ## Examples

      {Check.NPM, :exists?}
      {Check.NPM, :require_minimum_version, ["7.8.0"]}
      {Check.NPM, :installed?}
  """

  @doc """
  Checks the installed version of npm is greater than or equal to the declared version.
  """
  def require_minimum_version(minimum) do
    {version, 0} = System.cmd("npm", ["--version"])

    version
    |> String.trim()
    |> Version.compare(minimum)
    |> case do
      :lt ->
        {:error, version, "npm -g install npm"}

      _ ->
        :ok
    end
  end

  @doc """
  Checks that there is an npm executable installed locally.
  """
  def exists? do
    System.cmd("npm", ["--version"])
    |> case do
      {_output, 0} -> :ok
      {output, _status_code} -> {:error, output, "# asdf install ; or brew install nodejs"}
    end
  end

  @doc """
  Checks that the packages declared in assets/package-lock.json are all installed.
  """
  def all_packages_installed? do
    System.cmd("npm", ["outdated", "--prefix", "assets"])
    |> case do
      {output, 0} ->
        missing = output |> String.split("\n") |> Enum.filter(&Regex.match?(~r/MISSING/, &1))

        if length(missing) > 0,
          do: {:error, ["Some packages are not installed" | missing] |> Enum.join("\n"), "npm i --prefix assets"},
          else: :ok

      {output, _} ->
        {:error, output}
    end
  end

  @doc """
  Checks that npm install has been run at least once.
  """
  def any_packages_installed? do
    System.cmd("npm", ["list", "--prefix", "assets", "--dev"])
    |> case do
      {_output, 0} ->
        :ok

      {output, _status_code} ->
        {:error, output, "npm ci --prefix assets"}
    end
  end
end
