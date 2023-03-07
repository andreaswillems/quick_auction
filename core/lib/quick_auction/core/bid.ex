defmodule QuickAuction.Core.Bid do
  @moduledoc """
  Represents a bid.
  """
  use TypedStruct
  alias QuickAuction.Core.User

  typedstruct enforce: true do
    @typedoc "A bid"
    field :user, User.t()
    field :amount, integer()
    field :created_at, DateTime.t()
  end

  @spec new(User.t(), integer(), DateTime.t()) ::
          {:ok, __MODULE__.t()} | {:error, :wrong_argument_type}
  def new(user, amount, created_at)
      when is_struct(user, User) and is_integer(amount) and is_struct(created_at, DateTime) do
    {:ok, %__MODULE__{user: user, amount: amount, created_at: created_at}}
  end

  def new(_, _, _), do: {:error, :wrong_argument_type}
end
