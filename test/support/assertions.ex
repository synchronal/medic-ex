defmodule Test.Support.Assertions do
  @moduledoc """
  Assertions for
  """

  require ExUnit.Assertions

  @spec assert_eq(any(), any()) :: any()
  def assert_eq([first | _] = left, right) when is_struct(first),
    do: assert_eq(Enum.map(left, &Map.from_struct/1), right)

  def assert_eq(left, [first | _] = right) when is_struct(first),
    do: assert_eq(left, Enum.map(right, &Map.from_struct/1))

  def assert_eq(left, right) when is_struct(left), do: assert_eq(Map.from_struct(left), right)
  def assert_eq(left, right) when is_struct(right), do: assert_eq(left, Map.from_struct(right))

  def assert_eq(left, right) do
    ExUnit.Assertions.assert(left == right)
    left
  end
end
