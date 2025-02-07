defmodule Medic.Support.RuntimeVersionManager do
  @moduledoc false
  alias Medic.Cmd
  alias Medic.Etc
  alias Medic.Sugar
  alias Medic.System

  def current(plugin) do
    with {:ok, rvm} <- version_manager() do
      case rvm do
        "asdf" ->
          case Cmd.exec("asdf", ["current", plugin]) do
            {output, 0} ->
              output
              |> asdf_current()
              |> Sugar.ok()

            {output, _} ->
              {:error, output}
          end

        "mise" ->
          case Cmd.exec("mise", ["current", plugin]) do
            {output, 0} -> output |> String.trim() |> Sugar.ok()
            {output, _} -> {:error, output}
          end
      end
    end
  end

  @spec plugins() :: {:ok, [binary()]} | {:error, term()}
  def plugins do
    with {:ok, rvm} <- version_manager() do
      plugins =
        case rvm do
          "asdf" ->
            Cmd.exec!(rvm, ["plugin", "list"]) |> Etc.split_at_newlines()

          "mise" ->
            Etc.split_at_newlines(Cmd.exec!(rvm, ["plugins", "ls"])) ++
              Etc.split_at_newlines(Cmd.exec!(rvm, ["plugins", "--core"])) ++
              ["golang", "nodejs"]
        end

      {:ok, plugins}
    end
  end

  @spec plugins() :: {:ok, binary()} | {:error, term()}
  def version_manager do
    case ~w(mise asdf)
         |> Enum.find(&System.find_executable/1) do
      nil -> {:error, "no runtime version manager was found"}
      rvm -> {:ok, rvm}
    end
  end

  # # #

  defp asdf_current(output) do
    versions =
      case String.split(output, "\n") do
        ["Name " <> _, versions | _] -> versions
        [versions | _] -> versions
      end

    versions
    |> String.split(" ", trim: true)
    |> Enum.at(1)
  end
end
