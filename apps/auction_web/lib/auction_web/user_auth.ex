defmodule AuctionWeb.UserAuth do
  import Plug.Conn
  import Phoenix.Controller
  alias Auction.User

  # --- PARTE 1: O PLUG ---
  def fetch_current_user(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user = user_id && Auction.Repo.get(User, user_id)
    assign(conn, :current_user, user)
  end

  # --- PARTE 2: O HOOK ---
  # CORREÇÃO AQUI: Trocamos :mount_current_user por _key
  def on_mount(_key, _params, session, socket) do
    user_id = session["user_id"]
    user = user_id && Auction.Repo.get(User, user_id)

    socket =
      socket
      |> Phoenix.Component.assign(:current_user, user)

    {:cont, socket}
  end
end
