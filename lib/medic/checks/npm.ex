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
    cmd_in_dir(dir, "npm", ["ls", "--prefix", "assets", "--prefer-offline"], stderr_to_stdout: true)
    |> case do
      {output, 0} ->
        missing = output |> String.split("\n") |> Enum.filter(&Regex.match?(~r/UNMET DEPENDENCY/, &1))

        if length(missing) > 0,
          do: {:error, ["Some packages are not installed" | missing] |> Enum.join("\n"), remedy_in_dir(dir, "npm ci --prefix assets")},
          else: :ok

      {output, _} ->
        {:error, output, "npm ci --prefix assets"}
    end
  end

  @doc """
  Checks that npm install has been run at least once.

  Opts:
  - `cd`: The directory to run the command in.
  """
  @spec any_packages_installed?(opts :: Keyword.t()) :: Medic.Check.check_return_t()
  def any_packages_installed?(opts \\ []) do
    dir = Keyword.get(opts, :cd)
    cmd_in_dir(dir, "npm", ["list", "--prefix", "assets", "--dev"])
    |> case do
      {_output, 0} ->
        :ok

      {output, _status_code} ->
        {:error, output, remedy_in_dir(dir, "npm ci --prefix assets")}
    end
  end

  # # #


  defp cmd_in_dir(dir_or_nil, command, params, opts \\ [])
  defp cmd_in_dir(nil, command, params, opts), do: System.cmd(command, params, opts)
  defp cmd_in_dir(dir, command, params, opts), do: System.cmd(command, params, Keyword.merge(opts, cd: dir))

  defp remedy_in_dir(nil, remedy), do: remedy
  defp remedy_in_dir(dir, remedy), do: "(cd #{dir} && #{remedy})"
end
