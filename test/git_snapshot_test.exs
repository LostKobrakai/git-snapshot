defmodule GitSnapshotTest do
  alias ExUnit.AssertionError
  use ExUnit.Case
  import GitSnapshot

  describe "assert_snapshot" do
    test "no error for existing and unchanged file", context do
      assert_snapshot(context, "key", "abc")
    end

    test "no error for non-existing file", context do
      assert_snapshot(context, "key", "abc")
    end

    test "error for existing but changed file", context do
      on_exit(fn ->
        {_, 0} =
          System.cmd("git", [
            "restore",
            "snapshots/GitSnapshotTest/test-assert_snapshot-error-for-existing-but-changed-file-e4e091a3/key.txt"
          ])
      end)

      assert_raise AssertionError, fn ->
        assert_snapshot(context, "key", "def")
      end

      assert {_, 1} =
               System.cmd("git", [
                 "diff",
                 "--exit-code",
                 "snapshots/GitSnapshotTest/test-assert_snapshot-error-for-existing-but-changed-file-e4e091a3/key.txt"
               ])
    end

    test "error for uncomparable value", context do
      assert_raise RuntimeError, "uncomparable value: <<1, 2, 3>>", fn ->
        assert_snapshot(context, "key", <<1, 2, 3>>)
      end
    end

    test "protocol is called", context do
      assert_snapshot(context, "key", %TestStruct{value: <<1, 2, 3>>})
    end
  end

  describe "assert_json" do
    test "no error for existing and unchanged json data", context do
      assert_json(context, "key", Jason.encode!("abc"))
    end

    test "no error when data is semantically unchanged", context do
      assert_json(context, "key", ~s|{"b": "a","a": "b"}|)
    end

    test "no error for non-existing file", context do
      assert_json(context, "key", Jason.encode!("abc"))
    end

    test "error for existing but changed file", context do
      on_exit(fn ->
        {_, 0} =
          System.cmd("git", [
            "restore",
            "snapshots/GitSnapshotTest/test-assert_json-error-for-existing-but-changed-file-fff7b643/key.json"
          ])
      end)

      assert_raise AssertionError, fn ->
        assert_json(context, "key", Jason.encode!("def"))
      end

      assert {_, 1} =
               System.cmd("git", [
                 "diff",
                 "--exit-code",
                 "snapshots/GitSnapshotTest/test-assert_json-error-for-existing-but-changed-file-fff7b643/key.json"
               ])
    end

    test "error for uncomparable value", context do
      assert_raise RuntimeError, "uncomparable value: <<1, 2, 3>>", fn ->
        assert_json(context, "key", <<1, 2, 3>>)
      end
    end

    test "Jason.Encoder protocol is called", context do
      assert_json(context, "key", %TestStruct{value: <<1, 2, 3>>})
    end
  end

  describe "assert_image" do
    test "no error for existing and unchanged file", context do
      assert_image(context, "key.png", File.read!("test/fixture/before.png"))
    end

    test "no error for non-existing file", context do
      assert_image(context, "key.png", File.read!("test/fixture/before.png"))
    end

    test "error for existing but changed file", context do
      on_exit(fn ->
        {_, 0} =
          System.cmd("git", [
            "restore",
            "snapshots/GitSnapshotTest/test-assert_image-error-for-existing-but-changed-file-cebe8af7/key.png"
          ])
      end)

      assert_raise AssertionError, fn ->
        assert_image(context, "key.png", File.read!("test/fixture/after.png"))
      end

      assert {_, 1} =
               System.cmd("git", [
                 "diff",
                 "--exit-code",
                 "snapshots/GitSnapshotTest/test-assert_image-error-for-existing-but-changed-file-cebe8af7/key.png"
               ])
    end

    test "changes are dropped on successful runs", context do
      on_exit(fn ->
        {_, 0} =
          System.cmd("git", [
            "restore",
            "snapshots/GitSnapshotTest/test-assert_image-changes-are-dropped-on-successful-runs-e25335ca/key.png"
          ])
      end)

      assert_raise AssertionError, fn ->
        assert_image(context, "key.png", File.read!("test/fixture/after.png"))
      end

      assert_image(context, "key.png", File.read!("test/fixture/before.png"))

      assert {_, 0} =
               System.cmd("git", [
                 "diff",
                 "--exit-code",
                 "snapshots/GitSnapshotTest/test-assert_image-changes-are-dropped-on-successful-runs-e25335ca/key.png"
               ])
    end

    test "diffs are removed on successful runs", context do
      on_exit(fn ->
        {_, 0} =
          System.cmd("git", [
            "restore",
            "snapshots/GitSnapshotTest/test-assert_image-diffs-are-removed-on-successful-runs-8e09cb4b/key.png"
          ])
      end)

      assert_raise AssertionError, fn ->
        assert_image(context, "key.png", File.read!("test/fixture/after.png"))
      end

      assert_image(context, "key.png", File.read!("test/fixture/before.png"))

      refute File.exists?(
               "snapshots/GitSnapshotTest/test-assert_image-diffs-are-removed-on-successful-runs-8e09cb4b/key-diff.png"
             )
    end

    test "no error for barely different but changed file", context do
      on_exit(fn ->
        {_, 0} =
          System.cmd("git", [
            "restore",
            "snapshots/GitSnapshotTest/test-assert_image-error-for-existing-but-changed-file-cebe8af7/key.png"
          ])
      end)

      assert_image(context, "key.png", File.read!("test/fixture/barely_different.png"),
        threshold: 0.2
      )
    end

    test "error for uncomparable value", context do
      assert_raise RuntimeError, "uncomparable value: 4", fn ->
        assert_image(context, "key", 4)
      end
    end
  end
end
