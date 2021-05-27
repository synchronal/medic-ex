defmodule Medic.Checks do
  @moduledoc false

  @checks_dir ".medic/checks"

  def load_local_files do
    with :ok <- checks_dir_exists?(),
         {:ok, files} <- File.ls(@checks_dir) do
      for file <- files do
        Code.require_file(file, @checks_dir)
        :ok
      end
    else
      _ -> :ok
    end
  end

  defp checks_dir_exists? do
    if File.dir?(@checks_dir),
      do: :ok,
      else: {:error, :no_checks_dir}
  end
end
