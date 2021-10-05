defmodule TwexTest do
  use ExUnit.Case
  doctest Twex

  test "greets the world" do
    assert Twex.hello() == :world
  end
end
