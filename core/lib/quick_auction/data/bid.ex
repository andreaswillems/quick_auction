defmodule QuickAuction.Core.Data.Bid do
  @moduledoc false
  use TypedStruct
  alias QuickAuction.Core.Data.User

  typedstruct enforce: true do
    @typedoc "A bid"
    field :user, User.t()
    field :amount, integer()
    field :created_at, DateTime.t()
  end

  def new(user, amount, created_at)
      when is_struct(user, User) and is_integer(amount) and is_struct(created_at, DateTime) do
    {:ok, %__MODULE__{user: user, amount: amount, created_at: created_at}}
  end

  def new(_, _, _), do: {:error, :wrong_argument_type}
end
