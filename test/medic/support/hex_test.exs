defmodule Medic.Support.HexTest do
  use ExUnit.Case

  import Test.Support.Assertions
  alias Medic.Support.Hex

  describe "split" do
    test "is an empty list when no data goes in" do
      ""
      |> Hex.split()
      |> assert_eq([])
    end

    test "splits mix deps output into a list of dependencies" do
      """
      * acceptor_pool 1.0.0 (Hex package) (rebar3)
        locked at 1.0.0 (acceptor_pool) 0cbcd83f
        ok
      * benchee 1.0.1 (Hex package) (mix)
        locked at 1.0.1 (benchee) 3ad58ae7
        ok
      * joken (Hex package) (mix)
        locked at 2.4.0 (joken) 59990499
        the dependency build is outdated, please run "mix deps.compile"
      * tangent 0.2.4 (https://github.com/geometerio/tangent.git) (mix)
        locked at c3e7b64
        ok
      * telemetry 1.0.0 (Hex package) (rebar3)
        locked at 1.0.0 (telemetry) 73bc09fa
        ok
      """
      |> Hex.split()
      |> assert_eq([
        %{name: "acceptor_pool", version: "1.0.0", status: :ok},
        %{name: "benchee", version: "1.0.1", status: :ok},
        %{name: "joken", version: "2.4.0", status: :outdated},
        %{name: "tangent", version: "c3e7b64", status: :ok},
        %{name: "telemetry", version: "1.0.0", status: :ok}
      ])
    end
  end
end
