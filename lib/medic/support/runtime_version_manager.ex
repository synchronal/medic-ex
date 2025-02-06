defmodule Medic.Support.RuntimeVersionManager do
  @moduledoc false
  alias Medic.Cmd
  alias Medic.Etc
  alias Medic.Sugar

  def current(plugin) do
    with {:ok, rvm} <- version_manager() do
      case rvm do
        "asdf" ->
          case System.cmd("asdf", ["current", plugin]) do
            {output, 0} ->
              output
              |> String.split(" ", trim: true)
              |> Enum.at(4)
              |> Sugar.ok()

            {output, _} ->
              {:error, output}
          end

        "mise" ->
          case System.cmd("mise", ["current", plugin]) do
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
end
