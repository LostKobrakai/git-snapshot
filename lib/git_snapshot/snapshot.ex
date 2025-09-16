defprotocol GitSnapshot.Snapshot do
  @moduledoc """
  Protocol for data into their snapshot representations.

  Snapshots can only be printable string content or it won't be great for
  getting compared by humans / in git.

  ## Example

      defmodule TestStruct do
        defstruct value: <<1, 2, 3>>

        defimpl GitSnapshot.Snapshot do
          def to_string(struct) do
            Base.encode16(struct.value)
          end
        end
      end

  """

  @fallback_to_any true
  def to_string(t)
end

defimpl GitSnapshot.Snapshot, for: Any do
  def to_string(value), do: String.Chars.to_string(value)
end
