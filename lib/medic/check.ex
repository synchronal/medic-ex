defmodule Medic.Check do
  @moduledoc "Reusable check functions"

  def command_succeeds?(command, args, remedy: remedy) do
    case System.cmd(command, args) do
      {_output, 0} -> :ok
      {output, _} -> {:error, output, remedy}
    end
  end

  def in_list?(item, list, remedy: remedy),
    do: if(item in list, do: :ok, else: {:error, "“#{item}” not found in #{inspect(list)}", remedy})
end
