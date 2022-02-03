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

  Opts:
  - `cd`: The directory to run the command in.
  """
  @spec all_packages_installed?(opts :: Keyword.t()) :: Medic.Check.check_return_t()
  def all_packages_installed?(opts \\ []) do
    dir = Keyword.get(opts, :cd)

    {output, status} =
      Medic.Cmd.exec("npm", ["ls", "--prefix", "assets", "--prefer-offline"], Medic.Extra.Keyword.compact(cd: dir, stderr_to_stdout: true))

    if status != 0 || Regex.match?(~r/UNMET DEPENDENCY/, output),
      do: {:error, output, remedy_in_dir(dir, "npm ci --prefix assets")},
      else: :ok
  end

  @doc """
  Checks that npm install has been run at least once.

  Opts:
  - `cd`: The directory to run the command in.
  """
  @spec any_packages_installed?(opts :: Keyword.t()) :: Medic.Check.check_return_t()
  def any_packages_installed?(opts \\ []) do
    dir = Keyword.get(opts, :cd)

    Medic.Cmd.exec("npm", ["list", "--prefix", "assets", "--dev"], Medic.Extra.Keyword.compact(cd: dir))
    |> case do
      {_output, 0} -> :ok
      {output, _status_code} -> {:error, output, remedy_in_dir(dir, "npm ci --prefix assets")}
    end
  end

  # # #

  defp remedy_in_dir(nil, remedy), do: remedy
  defp remedy_in_dir(dir, remedy), do: "(cd #{dir} && #{remedy})"
end
