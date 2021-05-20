defmodule Medic.Check do
  @moduledoc "Reusable check functions"

  alias Medic.UI

  def run({module, meta_function}),
    do: run({module, meta_function, []})

  def run({module, function, args}) do
    UI.item(
      module |> Module.split() |> List.last(),
      function |> to_string() |> String.replace("_", " "),
      args
    )

    apply(module, function, args)
  end

  def command_succeeds?(command, args, remedy: remedy) do
    case System.cmd(command, args) do
      {_output, 0} -> :ok
      {output, _} -> {:error, output, remedy}
    end
  end

  def in_list?(item, list, remedy: remedy),
    do: if(item in list, do: :ok, else: {:error, "“#{item}” not found in #{inspect(list)}", remedy})
end
