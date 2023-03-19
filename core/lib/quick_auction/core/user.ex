defmodule QuickAuction.Core.User do
  @moduledoc """
  Represents an user.
  """
  use TypedStruct

  typedstruct enforce: true do
    @typedoc "A user"
    field :id, String.t()
    field :name, String.t()
    # field :email, String.t()
  end

  @spec new(binary) :: {:ok, QuickAuction.Core.User.t()}
  def new(name) when is_binary(name) do
    {:ok, %__MODULE__{id: Uniq.UUID.uuid4(), name: name}}
  end

  def _, do: {:error, :wrong_argument_type}
end
