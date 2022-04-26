defmodule Medic.Test do
  # @related [test](/test/medic/test_test.exs)

  @moduledoc """
  Common list of tests.

  ## Usage

  `Medic.Test` is run from a shell script generated at `bin/dev/test`:

      elixir -r .medic/require.exs -e "Medic.Test.run()" $*

  """
  def run(opts \\ []) do
    Medic.Cmd.run!("Compiling", "mix", ["compile", "--force", "--warnings-as-errors"], env: [{"MIX_ENV", "test"}])
    Medic.Cmd.run!("Running tests", "mix", ["test" | mix_test_options(opts)])
  end

  def mix_test_options(opts) do
    ["--color", "--warnings-as-errors" | opts]
  end
end
