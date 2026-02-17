defmodule TestStruct do
  defstruct value: <<1, 2, 3>>

  defimpl GitSnapshot.Snapshot do
    def to_string(struct) do
      Base.encode16(struct.value)
    end
  end

  defimpl Jason.Encoder do
    def encode(struct, opts) do
      Jason.Encode.string(Base.encode16(struct.value), opts)
    end
  end
end
