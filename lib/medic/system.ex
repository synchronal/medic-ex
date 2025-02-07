defmodule Medic.System do
  @moduledoc false

  @callback find_executable(binary()) :: binary() | nil

  defmodule RealSystem do
    @moduledoc false
    @behaviour Medic.System

    @impl Medic.System
    def find_executable(cmd), do: Elixir.System.find_executable(cmd)
  end

  def find_executable(cmd), do: impl().find_executable(cmd)

  # # #

  defp impl, do: Application.get_env(:medic, :system, Medic.System.RealSystem)
end
