defmodule Medic.Checks.Postgres do
  @moduledoc """
  Checks that Postgres is running, and is set up correctly.

  ## Examples

      {Check.Postgres, :running?},
      {Check.Postgres, :correct_version_running?},
      {Check.Postgres, :role_exists?},
      {Check.Postgres, :correct_data_directory?},
      {Check.Postgres, :database_exists?, ["my_db"]}

  ## Environment variables

  Medic uses `psql` in order to connect to Postgres for its checks. When using
  a non-standard configuration, such as database port, consider setting environment
  variables such as `PGPORT` (in `.envrc` or `.envrc.local`) to configure `psql` if
  possible.

  These environment variables are documented in
  [libpq's documentation](https://www.postgresql.org/docs/current/libpq-envars.html).
  """

  @default_data_dir "./priv/postgres/data"

  @doc """
  Checks that the named database exists in the running Postgres instance.

  ## Usage

      {Medic.Checks.Postgres, :database_exists?, ["my_db_dev"]}
      {Medic.Checks.Postgres, :database_exists?, ["my_db_dev", username: "postgres"]}
  """
  @spec database_exists?(binary()) :: Medic.Check.check_return_t()
  def database_exists?(database_name, opts \\ []) do
    {:ok, found_databases} = databases(List.wrap(opts))

    if database_name in found_databases,
      do: :ok,
      else: {:error, "#{database_name} not found in #{inspect(found_databases)}", "mix ecto.setup"}
  end

  @doc """
  Checks that the running Postgres database matches the version defined
  in ASDF's `.tool-versions` file.

  Options:
    * `remedy`: the remedy as a string
  """
  @spec correct_version_running?() :: Medic.Check.check_return_t()
  def correct_version_running?(opts \\ []) do
    with {:ok, project_version} <- get_project_version(),
         {:ok, running_version} <- get_running_version() do
      if project_version == running_version,
        do: :ok,
        else: {
          :error,
          "running database version #{running_version} does not match project version #{project_version}",
          Keyword.get(opts, :remedy, "bin/dev/db-restart")
        }
    else
      {:error, _} ->
        {:error, "Unable to determine desired or running postgres. Please check that the desired version is running.", "# remediate"}
    end
  end

  @doc """
  Checks that a user has been created in the running instance. This check defaults
  to the username `postgres` if not explicitly given.

  ## Usage

      {Medic.Checks.Postgres, :role_exists?}
      {Medic.Checks.Postgres, :role_exists?, ["postgres"]}
  """
  @spec role_exists?(binary()) :: Medic.Check.check_return_t()
  def role_exists?(username \\ "postgres") do
    System.cmd("psql", ["-A", "-c", "\\du", username], stderr_to_stdout: true)
    |> case do
      {output, 0} ->
        if output =~ "postgres",
          do: :ok,
          else: {:error, "postgres role does not exist", "createuser -s #{username} -U \$USER"}

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
      * `username`: username to use when calling psql

  ## Usage

      {Medic.Checks.Postgres, :correct_data_directory?}
      {Medic.Checks.Postgres, :correct_data_directory?, ["/path/to/data/directory"]}
      {Medic.Checks.Postgres, :correct_data_directory?, [data_directory: "/path/to/data/directory", username: "postgres"]}
      {Medic.Checks.Postgres, :correct_data_directory?, [data_directory: "/path/to/data/directory", remedy: "bin/dev/db-restart"]}

  """
  @spec correct_data_directory?(Path.t() | list()) :: Medic.Check.check_return_t()
  def correct_data_directory?(path_or_opts \\ @default_data_dir)

  def correct_data_directory?(path) when is_binary(path) do
    correct_data_directory?(data_directory: path)
  end

  def correct_data_directory?(opts) when is_list(opts) do
    expected_data_dir = opts |> Keyword.get(:data_directory, @default_data_dir) |> Path.expand()

    {actual_data_dir, 0} = System.cmd("psql", ["-tA", "-c", "SHOW data_directory;" | psql_opts(opts)], stderr_to_stdout: true)

    if String.trim(actual_data_dir) == expected_data_dir do
      :ok
    else
      {
        :error,
        "expected data directory to be #{expected_data_dir} but it was #{actual_data_dir}",
        Keyword.get(opts, :remedy, "# start postgres from #{expected_data_dir}")
      }
    end
  end

  @doc """
  Checks whether Postgres is running, by attempting to list all databases.

  Options:
    * `remedy`: the remedy as a string
    * `username`: username to use when calling psql

  """
  @spec running?(list()) :: Medic.Check.check_return_t()
  def running?(opts \\ []) do
    case databases(opts) do
      {:ok, _list} -> :ok
      {:error, output} -> {:error, output, Keyword.get(opts, :remedy, "# start postgres")}
    end
  end

  # # #

  defp databases(opts) do
    case System.cmd("psql", ["-l", "-x" | psql_opts(opts)], stderr_to_stdout: true) do
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

  defp psql_opts(opts) do
    case Keyword.fetch(opts, :username) do
      {:ok, username} -> ["-U", username]
      :error -> ["-U", "postgres"]
    end
  end
end
