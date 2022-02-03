defmodule Medic.Extra.KeywordTest do
  use ExUnit.Case

  alias Medic.Extra

  describe "compact" do
    test "removes entries whose values are nil" do
      assert Extra.Keyword.compact(a: 1, b: nil, c: 3) == [a: 1, c: 3]
    end
  end
end
