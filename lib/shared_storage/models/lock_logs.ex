defmodule SharedStorage.LockLogs do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :method, :ticket, :owner, :message, :wasted_time, :inserted_at, :updated_at]}

  schema "lock_logs" do
    field :method, :string
    field :ticket, :binary_id
    field :owner, :string
    field :message, :string
    field :wasted_time, :integer

    timestamps()
  end

  def changeset(log, attrs) do
    log
    |> cast(attrs, [:method, :ticket, :owner, :message, :wasted_time])
    |> validate_required([:method, :ticket, :owner, :message, :wasted_time])
  end
end
