defmodule Medic.Doctor do
  @moduledoc """
  Checks to ensure that the application can be run for development and tests.

  ## Usage

  `Medic.Doctor` is run from a shell script generated at `bin/dev/doctor`:

      elixir -r .medic/require.exs -e "Medic.Doctor.run()" $*

  ## Configuration

  See the guides for information on how to [Configure Doctor Checks](installation.html#configure-doctor-checks)
  for a specific project or how to write [Custom Checks](overview.html#local-checks).
  """

  alias Medic.Check
  alias Medic.Checks
  alias Medic.UI

  @default_checks [
    {Checks.Homebrew, :bundled?},
    {Checks.Direnv, :envrc_file_exists?},
    {Checks.Direnv, :has_all_keys?},
    {Checks.Hex, :local_hex_installed?},
    {Checks.Hex, :packages_installed?},
    {Checks.NPM, :exists?},
    {Checks.NPM, :require_minimum_version, ["7.8.0"]},
    {Checks.NPM, :any_packages_installed?},
    {Checks.NPM, :all_packages_installed?}
  ]

  def run do
    UI.heading("Running doctor checks")

    load_doctor_file()
    |> run()
  end

  def run([check | rest]) do
    case Check.run(check) do
      :ok ->
        UI.ok()
        run(rest)

      :skipped ->
        UI.skipped()
        run(rest)

      {:warn, output} ->
        UI.warn(output)
        run(rest)

      {:error, output, remedy} ->
        skipfile = Check.skip_file(check)
        failed(output, remedy, skipfile)
        System.halt(1)
    end
  end

  def run([]),
    do: IO.puts("")

  def failed(output, remedy, skipfile) do
    :ok = clipboard(remedy)

    UI.failed(output, [
      "\nPossible remedy: ",
      :yellow,
      remedy,
      :green,
      " (It's in the clipboard)",
      :cyan,
      "\nSkip: ",
      :yellow,
      "touch #{skipfile}"
    ])
  end

  def clipboard(cmd) do
    case System.find_executable("pbcopy") do
      nil ->
        {:error, "Cannot find pbcopy"}

      path ->
        port = Port.open({:spawn_executable, path}, [:binary, args: []])

        case cmd do
          cmd when is_binary(cmd) ->
            send(port, {self(), {:command, cmd}})

          cmd ->
            send(port, {self(), {:command, format(cmd)}})
        end

        send(port, {self(), :close})
        :ok
    end
  end

  defp format(value) do
    doc = Inspect.Algebra.to_doc(value, %Inspect.Opts{limit: :infinity})
    Inspect.Algebra.format(doc, :infinity)
  end

  defp load_doctor_file do
    if File.exists?(".medic/doctor.exs") do
      Code.eval_file(".medic/doctor.exs")
      |> case do
        {checks, []} -> checks
        _ -> raise "Expected .medic/doctor.exs to be a list of check tuples."
      end
    else
      @default_checks
    end
  end
end
