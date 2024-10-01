defmodule SharedStorage.LockLogs do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lock_logs" do
    field :method, :string
    field :ticket, :binary_id
    field :owner, :string
    field :lifetime, :integer

    timestamps()
  end

  def changeset(log, attrs) do
    log
    |> cast(attrs, [:method, :ticket, :owner, :lifetime])
    |> validate_required([:method, :ticket, :owner, :lifetime])
  end
end
