defmodule SharedStorage.Repo.Migrations.CreateLogs do
  use Ecto.Migration

  def change do
    create table(:lock_logs) do
      add :method, :string
      add :ticket, :binary_id
      add :owner, :string
      add :message, :string
      add :wasted_time, :integer

      timestamps()
    end
  end
end
