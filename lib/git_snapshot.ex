defmodule GitSnapshot do
  @moduledoc """
  `GitSnapshot` is a library for snapshot testing using `git`.

  This library takes string snaphots (see `m:GitSnapshot.Snapshot`) and stores
  them on disk. When a file exists the current test value will be compared to
  the staged content of that file.

  If the compared values are equal everything is fine.

  If the compared values are not equal the file is overwritten with the new value
  and an `ExUnit.AssertionError` is raised for the test to fail. The changed
  value can become accepted by staging the updated file contents.
  """
  import ExUnit.Assertions
  alias ExUnit.AssertionError

  @doc """
  Assert on a snapshot.

  ## Example

    test "name", context do
      assert_snapshot(context, "file_name", "value")
    end

  """
  def assert_snapshot(context, key, value) do
    string = GitSnapshot.Snapshot.to_string(value)

    if not is_binary(string) or not String.printable?(string) do
      raise "uncomparable value: #{inspect(string)}"
    end

    dir = create_tmp_dir!(context)
    path = Path.join(dir, "#{key}.txt")

    case System.cmd(ensure_git!(), ["show", ":#{path}"], stderr_to_stdout: true) do
      {expected, 0} ->
        try do
          assert string == expected
        rescue
          e in [AssertionError] ->
            File.write!(path, string)
            reraise(e, __STACKTRACE__)
        end

      {_, 128} ->
        File.write!(path, string)
        :ok
    end
  end

  @doc """
  Assert on a image.

  ## Example

    test "name", context do
      assert_image(context, "file_name.png", image)
    end

  """
  if Code.ensure_compiled!(Image) do
    def assert_image(context, key, image) do
      if not is_binary(image) do
        raise "uncomparable value: #{inspect(image)}"
      end

      dir = create_tmp_dir!(context)
      path = Path.join(dir, key)

      case System.cmd(ensure_git!(), ["show", ":#{path}"], stderr_to_stdout: true) do
        {expected, 0} ->
          given_img = Image.open!(image)
          expected_img = Image.open!(expected)

          try do
            {:ok, hamming_distance} = Image.hamming_distance(given_img, expected_img)
            assert hamming_distance <= 10
            assert image == expected
          rescue
            e in [AssertionError] ->
              File.write!(path, image)
              reraise(e, __STACKTRACE__)
          end

        {_, 128} ->
          File.write!(path, image)
          :ok
      end
    end
  else
    def assert_image(_context, _key, _image) do
      raise "Install optional dependency :image"
    end
  end

  defp ensure_git! do
    case System.find_executable("git") do
      nil -> raise "git not found"
      path -> path
    end
  end

  defp create_tmp_dir!(context) do
    module_string = inspect(context.module)
    name_string = to_string(context.test)

    module = escape_path(module_string)
    name = escape_path(name_string)
    short_hash = short_hash(module_string, name_string)

    path = ["snapshots", module, "#{name}-#{short_hash}"] |> Path.join()
    File.mkdir_p!(Path.expand(path))
    path
  end

  @escape Enum.map(~c" [~#%&*{}\\:<>?/+|\"]", &<<&1::utf8>>)

  defp escape_path(path) do
    String.replace(path, @escape, "-")
  end

  defp short_hash(module, test_name) do
    (module <> "/" <> test_name)
    |> :erlang.md5()
    |> Base.encode16(case: :lower)
    |> binary_slice(0..7)
  end
end
