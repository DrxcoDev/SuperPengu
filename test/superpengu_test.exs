defmodule SuperpenguTest do
  use ExUnit.Case
  doctest Superpengu

  test "greets the world" do
    assert Superpengu.hello() == :world
  end
end
