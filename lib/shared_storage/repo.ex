defmodule SharedStorage.Repo do
  use Ecto.Repo,
    otp_app: :shared_storage,
    adapter: Ecto.Adapters.Postgres
end
