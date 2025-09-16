defmodule GitSnapshotTest do
  use ExUnit.Case
  doctest GitSnapshot

  test "greets the world" do
    assert GitSnapshot.hello() == :world
  end
end
