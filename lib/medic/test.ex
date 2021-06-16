defmodule Medic.Test do
  @moduledoc """
  Common list of tests.

  ## Usage

  `Medic.Test` is run from a shell script generated at `bin/dev/test`:

      elixir -r .medic/require.exs -e "Medic.Test.run()" $*

  """
  def run do
    Medic.Cmd.run!("Compiling", "mix", ["compile", "--force", "--warnings-as-errors"], env: [{"MIX_ENV", "test"}])
    Medic.Cmd.run!("Running tests", "mix", ["test", "--color"])
  end
end
