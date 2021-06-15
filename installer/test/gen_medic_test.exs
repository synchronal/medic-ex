defmodule GenMedicTest do
  use ExUnit.Case
  doctest GenMedic

  test "greets the world" do
    assert GenMedic.hello() == :world
  end
end
