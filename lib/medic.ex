defmodule Medic do
  @moduledoc """
  Documentation for `Medic`.
  """

  def start(_type, _args) do
    Medic.Checks.load_local_files()
    {:ok, self()}
  end
end
