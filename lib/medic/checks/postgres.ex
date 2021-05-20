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
  def database_exists?(database_name) do
    {:ok, found_tables} = tables()

    if database_name in found_tables,
      do: :ok,
      else: {:error, "#{database_name} not found in #{inspect(found_tables)}", "mix ecto.setup"}
  end

  @doc """
  Verifies that the running Postgres database matches the version defined
  in ASDF's `.tool-versions` file.
  """
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

  def role_exists? do
    {output, 0} = System.cmd("psql", ["-A", "-c", "\\du", "postgres"])

    if output =~ "postgres",
      do: :ok,
      else: {:error, "postgres role does not exist", "createuser -s postgres -U \$USER"}
  end

  def correct_data_directory? do
    {output, 0} = System.cmd("psql", ["-U", "postgres", "-tA", "-c", "SHOW data_directory;"])

    expected_data_dir = Path.expand("../../../priv/postgres/data", __DIR__)

    if String.trim(output) == expected_data_dir,
      do: :ok,
      else: {:error, "expected data directory to be #{expected_data_dir} but it was #{output}", "bin/dev/db-restart"}
  end

  def running? do
    case tables() do
      {:ok, _list} -> :ok
      {:error, output} -> {:error, output, "bin/dev/db-start"}
    end
  end

  defp tables do
    case System.cmd("psql", ["-l", "-x"]) do
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
    case System.cmd("psql", ["--version"]) do
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
