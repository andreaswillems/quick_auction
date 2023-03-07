defmodule QuickAuction.Core.User do
  @moduledoc """
  Represents an user.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A user"

    field :name, String.t(), enforce: true
    # field :email, String.t()
  end

  @spec new(binary) :: {:ok, QuickAuction.Core.User.t()}
  def new(name) when is_binary(name) do
    {:ok, %__MODULE__{name: name}}
  end

  def _, do: {:error, :wrong_argument_type}
end
