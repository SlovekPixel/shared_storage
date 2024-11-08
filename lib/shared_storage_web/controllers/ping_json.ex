defmodule SharedStorageWeb.PingController do
  use SharedStorageWeb, :controller

  def ping(conn, _params) do
    json(conn, %{"pong" => true})
  end
end