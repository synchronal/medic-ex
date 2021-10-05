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
  If run with no arguments, this expects that the data directory is located at `.priv/postgres/data`
  within the current project.

  ## Usage

      {Medic.Checks.Postgres, :correct_data_directory}
      {Medic.Checks.Postgres, :correct_data_directory, ["/path/to/data/directory"]}

  """
  @spec correct_data_directory?(Path.t()) :: Medic.Check.check_return_t()
  def correct_data_directory?(path \\ "./priv/postgres/data") do
    {output, 0} = System.cmd("psql", ["-U", "postgres", "-tA", "-c", "SHOW data_directory;"], stderr_to_stdout: true)

    expected_data_dir = Path.expand(path)

    if String.trim(output) == expected_data_dir,
      do: :ok,
      else: {:error, "expected data directory to be #{expected_data_dir} but it was #{output}", "# start postgres from #{path}"}
  end

  @doc """
  Checks whether Postgres is running, by attempting to list all databases.
  """
  @spec running?() :: Medic.Check.check_return_t()
  def running? do
    case databases() do
      {:ok, _list} -> :ok
      {:error, output} -> {:error, output, "# start postgres"}
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
