defmodule Medic.Update do
  @moduledoc """
  Performs a list of commands to update a project.

  ## Usage

  `Medic.Update` is run from a shell script generated at `bin/dev/update`:

      elixir -r .medic/require.exs -e "Medic.Update.run()" $*

  ## Configuration

  See the guides for information on how to [Configure Update Checks](installation.html#configure-update-commands).
  """

  alias Medic.UI

  @documentation_url "https://hexdocs.pm/medic/installation.html#configure-update-commands"

  @doc "Runs the commands listed in `.medic/update.exs`."
  def run, do: read_commands() |> Enum.each(&run_command/1)

  defp run_command(:build_mix) do
    {dev_output, 0} = System.cmd("mix", ["deps"], env: [{"MIX_ENV", "dev"}])
    {test_output, 0} = System.cmd("mix", ["deps"], env: [{"MIX_ENV", "test"}])
    dev_outdated = Medic.Support.Hex.split(dev_output) |> Enum.filter(fn dep -> dep.status == :outdated end)
    test_outdated = Medic.Support.Hex.split(test_output) |> Enum.filter(fn dep -> dep.status == :outdated end)

    if dev_outdated == [] && test_outdated == [] do
      UI.heading("Rebuilding mix deps", ["mix", "deps.compile"], inline: true)
      UI.skipped()
    end

    if dev_outdated != [] do
      dev_outdated_libs = dev_outdated |> Enum.map(& &1.name)
      run_command(["Rebuilding mix deps (dev)", "mix", ["deps.compile" | dev_outdated_libs], [env: [{"MIX_ENV", "dev"}]]])
    end

    if test_outdated != [] do
      test_outdated_libs = test_outdated |> Enum.map(& &1.name)
      run_command(["Rebuilding mix deps (test)", "mix", ["deps.compile" | test_outdated_libs], [env: [{"MIX_ENV", "test"}]]])
    end
  end

  defp run_command(:update_code) do
    run_command(["Updating code", "git", ["pull", "--rebase"]])
    Medic.Checks.load_local_files()
  end

  defp run_command(:update_mix), do: run_command(["Updating mix deps", "mix", ["deps.get"], [env: [{"MIX_QUIET", "true"}]]])
  defp run_command(:update_npm), do: run_command(["Updating npm deps", "npm", ["install", "--prefix", "assets"]])
  defp run_command(:build_npm), do: run_command(["Rebuilding JS", "npm", ["run", "build", "--prefix", "assets"]])
  defp run_command(:migrate), do: run_command(["Running migrations", "mix", ["ecto.migrate"]])
  defp run_command(:doctor), do: Medic.Doctor.run()
  defp run_command([description, command, args]), do: Medic.Cmd.run!(description, command, args)
  defp run_command([description, command, args, opts]), do: Medic.Cmd.run!(description, command, args, opts)

  defp read_commands do
    if File.exists?(".medic/update.exs") do
      case Code.eval_file(".medic/update.exs") do
        {commands, []} when is_list(commands) -> commands
        _ -> raise "Expected `.medic/update.exs` to be a list of commands. See #{@documentation_url}"
      end
    else
      raise "File `.medic/update.exs` not found. See #{@documentation_url}"
    end
  end
end
