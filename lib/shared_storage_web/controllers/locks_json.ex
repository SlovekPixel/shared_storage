defmodule SharedStorageWeb.LocksController do
  use SharedStorageWeb, :controller
  alias SharedStorage.Repo
  alias SharedStorage.LockLogs
  import Ecto.Query

  def index(conn, params) do
    page = Map.get(params, "page", "1") |> String.to_integer()
    per_page = Map.get(params, "per_page", "3") |> String.to_integer()
    method = Map.get(params, "method", nil)
    offset = (page - 1) * per_page

    locks_query =
      LockLogs
      |> limit([l], ^per_page)
      |> offset([l], ^offset)

    locks_query =
      if method do
        locks_query |> where([l], l.method == ^method)
      else
        locks_query
      end

    locks = Repo.all(locks_query)

    json(conn, locks)
  end
end