defmodule Medic.Etc do
  @moduledoc """
  Helper functions.
  """

  def application_version(path, version_flag),
    do:
      Medic.Cmd.exec!(path, [version_flag])
      |> then(&match_version/1)

  def split_at_newlines(string),
    do:
      string
      |> String.split("\n", trim: true)

  defp match_version(version_string) do
    Regex.run(~r/\D*(\d+\.\d+.\d+)/, version_string) |> Enum.at(1)
  end
end
