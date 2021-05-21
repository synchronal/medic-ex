defmodule Medic.Checks.Direnv do
  @moduledoc """
  Direnv - unclutter your .profile

  https://direnv.net

  ## Examples

      {Check.Direnv, :envrc_file_exists?}
      {Check.Direnv, :has_all_keys?}
  """

  @doc """
  Checks to make sure that `.envrc` exists in the project root directory.
  """
  def envrc_file_exists? do
    if File.exists?(path()),
      do: :ok,
      else: {:error, "File not found: #{path()}", "touch #{path()}"}
  end

  @doc """
  Compares keys in `.envrc.sample` and `.envrc`, to ensure that all sample
  keys have a real export.
  """
  def has_all_keys? do
    diff = List.myers_difference(keys(), keys(".sample"))
    keys = Keyword.keys(diff)

    cond do
      keys == [:eq] ->
        :ok

      Enum.member?(keys, :ins) ->
        message = """
        .envrc and .envrc.sample keys do not match
        in .envrc but not .envrc.sample: #{Keyword.get(diff, :del) |> inspect()}
        in .envrc.sample but not .envrc: #{Keyword.get(diff, :ins) |> inspect()}
        """

        {:error, message, "# make .envrc have the same keys as .envrc.sample"}

      true ->
        message = """
        in .envrc but not .envrc.sample: #{Keyword.get(diff, :del) |> inspect()}
        be sure essential keys from local .envrc are added to .envrc.sample
        """

        {:warn, message}
    end
  end

  defp keys(suffix \\ ""),
    do:
      Regex.scan(~r"^export ([^\s=]+)="m, File.read!(path(suffix)))
      |> Enum.map(&Enum.at(&1, 1))
      |> Enum.sort()

  defp path(suffix \\ ""),
    do: Path.expand(".envrc#{suffix}")
end
