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
  @spec require_minimum_version(binary()) :: Medic.Check.check_return_t()
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
  @spec exists?() :: Medic.Check.check_return_t()
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
  @spec all_packages_installed?() :: Medic.Check.check_return_t()
  def all_packages_installed? do
    System.cmd("npm", ["ls", "--prefix", "assets", "--prefer-offline"], stderr_to_stdout: true)
    |> case do
      {output, 0} ->
        missing = output |> String.split("\n") |> Enum.filter(&Regex.match?(~r/UNMET DEPENDENCY/, &1))

        if length(missing) > 0,
          do: {:error, ["Some packages are not installed" | missing] |> Enum.join("\n"), "npm ci --prefix assets"},
          else: :ok

      {output, _} ->
        {:error, output, "npm ci --prefix assets"}
    end
  end

  @doc """
  Checks that npm install has been run at least once.
  """
  @spec any_packages_installed?() :: Medic.Check.check_return_t()
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
