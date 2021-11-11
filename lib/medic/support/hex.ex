defmodule Medic.Support.Hex do
  @moduledoc false

  defmodule Dep do
    @moduledoc false
    defstruct [:name, :version, :status]
  end

  def split(""), do: []
  def split(mix_deps), do: do_split(mix_deps, {nil, []})

  defp do_split("", {current_dep, accumulator}), do: [parse_dep(current_dep) | accumulator] |> Enum.reverse()
  defp do_split("* " <> rest, {nil, accumulator}), do: do_split(rest, {<<>>, accumulator})
  defp do_split("* " <> _ = next, {current_dep, accumulator}), do: do_split(next, {nil, [parse_dep(current_dep) | accumulator]})
  defp do_split(<<letter::binary-size(1)>> <> rest, {current_dep, accumulator}), do: do_split(rest, {current_dep <> letter, accumulator})

  defp parse_dep(dep) do
    [names, lock, status] = dep |> String.trim() |> String.split("\n")
    [name | _] = String.split(names, " ")
    ["locked", "at", version | _] = lock |> String.trim() |> String.split(" ")
    %Dep{name: name, version: version, status: status_atom(status)}
  end

  defp status_atom("  ok"), do: :ok
  defp status_atom(_), do: :outdated
end
