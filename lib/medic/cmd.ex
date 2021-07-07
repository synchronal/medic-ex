defmodule Medic.Cmd do
  @moduledoc """
  Helpers for running commands.
  """
  alias Medic.UI

  @doc """
  Run a command, writing the description, command, and output to stdout.
  Returns `:ok` or raises if the command fails.
  """
  @spec run!(binary(), binary(), list(binary()), list()) :: :ok
  def run!(description, command, args, opts \\ []) do
    case run(description, command, args, opts) do
      {_output, 0} -> :ok
      {_output, status_code} -> raise error_message(command, args, status_code)
    end
  end

  @doc """
  Run a command, writing the description, command, and output to stdout.
  Returns result of `System.cmd`.
  """
  @spec run(binary(), binary(), list(binary()), list()) :: {binary(), integer()}
  def run(description, command, args, opts \\ []) do
    check = Keyword.get(opts, :check)

    if check do
      case Medic.Check.run(check) do
        {:error, _output, _remedy} ->
          IO.puts("")
          run(description, command, args, [])

        _check ->
          IO.puts("")
          UI.heading(description, [command | args])
          IO.puts("")
          {"Already compiled", 0}
      end
    else
      UI.heading(description, [command | args])
      result = System.cmd(command, args, opts |> Keyword.merge(into: IO.stream(:stdio, 1)))
      IO.puts("")
      result
    end
  end

  @doc """
  Run a command, returning trimmed output, or raising if the command fails.
  """
  @spec exec!(binary(), list(binary())) :: binary()
  def exec!(command, args) do
    case System.cmd(command, args) do
      {output, 0} -> output |> String.trim()
      {output, status_code} -> raise error_message(command, args, status_code, output)
    end
  end

  defp error_message(command, args, status_code, output \\ nil) do
    maybe_output = if output, do: [":", output], else: nil

    ["command", command, args, "failed with status code", status_code, maybe_output]
    |> Enum.reject(&is_nil(&1))
    |> Enum.join(" ")
  end
end
