defmodule Medic.Update do
  @moduledoc """
  Default update command for a Phoenix application.
  """
  def run do
    Medic.Cmd.run!("Updating project", "git", ["pull", "--rebase"])
    Medic.Cmd.run!("Updating mix deps", "mix", ["deps.get"], env: [{"MIX_QUIET", "true"}])
    Medic.Cmd.run!("Updating npm deps", "npm", ["install", "--prefix", "assets"])
    Medic.Cmd.run!("Rebuilding JS", "npm", ["run", "build", "--prefix", "assets"])
    Medic.Doctor.run()
  end
end
