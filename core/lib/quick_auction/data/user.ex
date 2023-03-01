defmodule QuickAuction.Core.Data.User do
  @moduledoc false
  use TypedStruct

  typedstruct do
    @typedoc "A user"

    field :name, String.t(), enforce: true
    # field :email, String.t()
  end
end
