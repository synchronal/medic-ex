defmodule Medic.TestTest do
  # @related [subject](lib/medic/test.ex)

  use ExUnit.Case, async: true

  describe "mix_test_options" do
    test "returns the defaults when no options are passed" do
      assert Medic.Test.mix_test_options([]) == ["--color", "--warnings-as-errors"]
    end

    test "appends the given options" do
      assert Medic.Test.mix_test_options(["--include", "external:true"]) == ["--color", "--warnings-as-errors", "--include", "external:true"]
    end
  end
end
