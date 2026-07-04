defmodule DiscountDslTest do
  use ExUnit.Case
  doctest DiscountDsl

  test "greets the world" do
    assert DiscountDsl.hello() == :world
  end
end
