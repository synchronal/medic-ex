defmodule Medic.Test do
  @moduledoc """
  Common list of tests.
  """
  def run do
    Medic.Cmd.run!("Compiling", "mix", ["compile", "--force", "--warnings-as-errors"], env: [{"MIX_ENV", "test"}])
    Medic.Cmd.run!("Running tests", "mix", ["test", "--color"])
  end
end
