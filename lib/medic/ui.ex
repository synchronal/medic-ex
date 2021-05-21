defmodule Medic.UI do
  @moduledoc false

  def failed(output, message),
    do:
      [" ", :red, :bright, "FAILED\n\n", :normal, output, :cyan, message, "\n"]
      |> format()
      |> IO.puts()

  def heading(message, details \\ nil),
    do:
      [:green, "▸ ", :bright, :light_cyan, message, details_to_chardata(details), "..."]
      |> format()
      |> IO.puts()

  def item(message, sub_message, details),
    do:
      [:green, "• ", :cyan, message, ": ", sub_message, details_to_chardata(details)]
      |> format()
      |> IO.write()

  def ok,
    do:
      [" ", :green, :bright, "OK"]
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

  defp details_to_chardata(details),
    do: [" (", :yellow, details |> List.wrap() |> Enum.intersperse(" "), :cyan, ")"]

  defp format(chardata) when is_list(chardata),
    do: IO.ANSI.format(chardata, true)
end
