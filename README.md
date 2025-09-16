# GitSnapshot

`GitSnapshot` is a library for snapshot testing using `git`.

This library takes string snaphots (see `m:GitSnapshot.Snapshot`) and stores
them on disk. When a file exists the current test value will be compared to
the staged content of that file.

If the compared values are equal everything is fine.

If the compared values are not equal the file is overwritten with the new value
and an `ExUnit.AssertionError` is raised for the test to fail. The changed
value can become accepted by staging the updated file contents.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `git_snapshot` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:git_snapshot, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/git_snapshot>.
