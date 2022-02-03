defmodule Medic.Extra.Keyword do
  @moduledoc "Keyword helpers"

  def compact(enum), do: Enum.reject(enum, fn {_k, v} -> v == nil end)
end
