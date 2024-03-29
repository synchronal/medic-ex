defmodule Medic.UI do
  @moduledoc false

  def failed(output, message),
    do:
      [" ", :red, :bright, "FAILED\n\n", :normal, output, :cyan, message, "\n", :normal]
      |> format()
      |> IO.puts()

  def heading(message, details \\ nil, opts \\ [])

  def heading(message, details, inline: true),
    do:
      [:green, "▸ ", :bright, :light_cyan, message, details_to_chardata(details), "...", :normal]
      |> format()
      |> IO.write()

  def heading(message, details, _opts),
    do:
      [:green, "▸ ", :bright, :light_cyan, message, details_to_chardata(details), "...", :normal]
      |> format()
      |> IO.puts()

  def item(message, sub_message, details),
    do:
      [:green, "• ", :cyan, message, ": ", sub_message, details_to_chardata(details), :normal]
      |> format()
      |> IO.write()

  def ok,
    do:
      [" ", :green, :bright, "OK"]
      |> format()
      |> IO.puts()

  def skipped,
    do:
      [" ", :yellow, :bright, "SKIPPED"]
      |> format()
      |> IO.puts()

  def warn(output),
    do:
      [" ", :yellow, :bright, "WARN\n", :normal, output, :cyan]
      |> format()
      |> IO.puts()

  # # #

  defp details_to_chardata(nil),
    do: []

  defp details_to_chardata([]),
    do: []

  defp details_to_chardata([opts]) when is_list(opts),
    do: details_to_chardata(inspect(opts))

  defp details_to_chardata(details) do
    if Keyword.keyword?(details) do
      [" (", :yellow, inspect(details), :cyan, ")"]
    else
      [" (", :yellow, details |> List.wrap() |> Enum.map(&flatten_tuples/1) |> Enum.intersperse(", "), :cyan, ")"]
    end
  end

  defp flatten_tuples({key, value}), do: [to_string(key), ": ", value]
  defp flatten_tuples(value) when is_binary(value), do: value
  defp flatten_tuples(value) when is_atom(value), do: ":#{value}"

  defp format(chardata) when is_list(chardata),
    do: IO.ANSI.format(chardata, true)
end
