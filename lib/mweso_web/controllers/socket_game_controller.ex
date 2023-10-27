defmodule MwesoWeb.SocketGameController do
  use MwesoWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
