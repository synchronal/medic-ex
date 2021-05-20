defmodule Medic.Doctor do
  @moduledoc """
  Checks to ensure that the application can be run for development and tests.
  """

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
    case run_check(check) do
      :ok ->
        UI.ok()
        run(rest)

      {:warn, output} ->
        UI.warn(output)
        run(rest)

      {:error, output, remedy} ->
        failed(output, remedy)
        System.halt(1)
    end
  end

  def run([]),
    do: IO.puts("")

  def run_check({module, meta_function}),
    do: run_check({module, meta_function, []})

  def run_check({module, function, args}) do
    UI.item(
      module |> Module.split() |> List.last(),
      function |> to_string() |> String.replace("_", " "),
      args
    )

    apply(module, function, args)
  end

  def failed(output, remedy) do
    :ok = clipboard(remedy)
    UI.failed(output, ["\nPossible remedy: ", :yellow, remedy, :green, "\n(It's in the clipboard)"])
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

  defp load_doctor_file() do
    if File.exists?(".doctor.exs") do
      Code.eval_file(".doctor.exs")
      |> case do
        {checks, []} -> checks
        _ -> raise "Expected .doctor.exs to be a list of check tuples."
      end
    else
      @default_checks
    end
  end
end
