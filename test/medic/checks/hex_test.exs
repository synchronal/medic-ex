defmodule Medic.Checks.HexTest do
  # @related [subject](lib/medic/checks/hex.ex)
  use ExUnit.Case, async: false
  alias Medic.Checks.Hex

  describe "rebar_path" do
    setup do
      original_mix_home = System.get_env("MIX_HOME")

      on_exit(fn ->
        if original_mix_home do
          System.put_env("MIX_HOME", original_mix_home)
        else
          System.delete_env("MIX_HOME")
        end
      end)

      [original_mix_home: original_mix_home]
    end

    test "is elixir/MAJOR-MINOR/rebar3 in MIX_HOME" do
      System.put_env("MIX_HOME", "/path/to/mix")

      {:ok, %{major: 1, minor: minor}} = System.version() |> Version.parse()
      expected_path = Path.join(["/path/to/mix", "elixir", "1-#{minor}", "rebar3"])
      assert ^expected_path = Hex.rebar_path()
    end

    test "is ~/.mix/elixir/MAJOR-MINOR/rebar3 when MIX_HOME does not exist" do
      System.delete_env("MIX_HOME")

      {:ok, %{major: 1, minor: minor}} = System.version() |> Version.parse()
      expected_path = Path.join([System.get_env("HOME"), ".mix", "elixir", "1-#{minor}", "rebar3"])
      assert ^expected_path = Hex.rebar_path()
    end
  end
end
