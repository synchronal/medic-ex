defmodule Medic.Checks.HexTest do
  # @related [subject](lib/medic/checks/hex.ex)
  use ExUnit.Case
  alias Medic.Checks.Hex

  describe "rebar_path" do
    test "test" do
      {:ok, %{major: 1, minor: minor}} = System.version() |> Version.parse()
      expected_path = Path.join([System.fetch_env!("MIX_HOME"), "elixir", "1-#{minor}", "rebar3"])
      assert ^expected_path = Hex.rebar_path()
    end
  end
end
