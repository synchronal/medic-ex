defmodule Medic.Checks.Postgres do
  @moduledoc """
  Checks that Postgres is running, and is set up correctly.

  ## Examples

      {Check.Postgres, :running?},
      {Check.Postgres, :correct_version_running?},
      {Check.Postgres, :role_exists?},
      {Check.Postgres, :correct_data_directory?},
      {Check.Postgres, :database_exists?, ["my_db"]}
  """

  @default_data_dir "./priv/postgres/data"

  @doc """
  Checks that the named database exists in the running Postgres instance.

  ## Usage

      {Medic.Checks.Postgres, :database_exists?, ["my_db_dev"]}
  """
  @spec database_exists?(binary()) :: Medic.Check.check_return_t()
  def database_exists?(database_name) do
    {:ok, found_databases} = databases()

    if database_name in found_databases,
      do: :ok,
      else: {:error, "#{database_name} not found in #{inspect(found_databases)}", "mix ecto.setup"}
  end

  @doc """
  Checks that the running Postgres database matches the version defined
  in ASDF's `.tool-versions` file.
  """
  @spec correct_version_running?() :: Medic.Check.check_return_t()
  def correct_version_running? do
    {:ok, project_version} = get_project_version()
    {:ok, running_version} = get_running_version()

    if project_version == running_version,
      do: :ok,
      else: {
        :error,
        "running database version #{running_version} does not match project version #{project_version}",
        "bin/dev/db-restart"
      }
  end

  @doc """
  Checks that a user `postgres` has been created in the running instance.
  """
  @spec role_exists?() :: Medic.Check.check_return_t()
  def role_exists? do
    System.cmd("psql", ["-A", "-c", "\\du", "postgres"], stderr_to_stdout: true)
    |> case do
      {output, 0} ->
        if output =~ "postgres",
          do: :ok,
          else: {:error, "postgres role does not exist", "createuser -s postgres -U \$USER"}

      {output, _} ->
        {:error, output, "# start postgres"}
    end
  end

  @doc """
  Checks that the running instance of Postgres has the expected data directory.

  If run with no arguments, this expects that the data directory is located at `#{@default_data_dir}`
  within the current project.

  If run with one argument, the argument can be:
    * A path to the data directory, or
    * A keyword list with one or more of the following keys:
      * `data_directory`: the path to the data directory
      * `remedy`: the remedy as a string

  ## Usage

      {Medic.Checks.Postgres, :correct_data_directory?}
      {Medic.Checks.Postgres, :correct_data_directory?, ["/path/to/data/directory"]}
      {Medic.Checks.Postgres, :correct_data_directory?, [data_directory: "/path/to/data/directory", remedy: "bin/dev/db-restart"]}

  """
  @spec correct_data_directory?(Path.t() | list()) :: Medic.Check.check_return_t()
  def correct_data_directory?(path_or_opts \\ @default_data_dir)

  def correct_data_directory?(path) when is_binary(path) do
    correct_data_directory?(data_directory: path)
  end

  def correct_data_directory?(opts) when is_list(opts) do
    expected_data_dir = opts |> Keyword.get(:data_directory, @default_data_dir) |> Path.expand()
    remedy = opts |> Keyword.get(:remedy, "# start postgres from #{expected_data_dir}")

    {actual_data_dir, 0} = System.cmd("psql", ["-U", "postgres", "-tA", "-c", "SHOW data_directory;"], stderr_to_stdout: true)

    if String.trim(actual_data_dir) == expected_data_dir,
      do: :ok,
      else: {:error, "expected data directory to be #{expected_data_dir} but it was #{actual_data_dir}", remedy}
  end

  @doc """
  Checks whether Postgres is running, by attempting to list all databases.

  Options:
    * `remedy`: the remedy as a string

  """
  @spec running?(list()) :: Medic.Check.check_return_t()
  def running?(opts \\ []) do
    case databases() do
      {:ok, _list} -> :ok
      {:error, output} -> {:error, output, Keyword.get(opts, :remedy, "# start postgres")}
    end
  end

  def databases do
    case System.cmd("psql", ["-l", "-x"], stderr_to_stdout: true) do
      {output, 0} ->
        {:ok, Regex.scan(~r"^Name\s+\| (\w+)\s*$"m, output) |> Enum.map(&List.last/1)}

      {output, _} ->
        {:error, output}
    end
  end

  defp get_project_version do
    case System.cmd("asdf", ["current", "postgres"]) do
      {output, 0} ->
        output
        |> String.split(" ", trim: true)
        |> Enum.at(1)
        |> ok()

      {output, _} ->
        {:error, output}
    end
  end

  defp get_running_version do
    case System.cmd("psql", ["--version"], stderr_to_stdout: true) do
      {output, 0} ->
        output
        |> String.split(" ", trim: true)
        |> Enum.at(2)
        |> String.trim()
        |> ok()

      {output, _} ->
        {:error, output}
    end
  end

  defp ok(result) do
    {:ok, result}
  end
end
