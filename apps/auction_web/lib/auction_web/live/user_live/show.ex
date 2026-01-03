defmodule AuctionWeb.UserLive.Show do
  use AuctionWeb, :live_view
  alias Auction

  # 1. Importamos para usar format_currency e format_datetime no HTML
  import AuctionWeb.Formatters

  def mount(%{"id" => id}, _session, socket) do
    current_user = socket.assigns.current_user

    cond do
      is_nil(current_user) ->
        {:ok,
         socket
         |> put_flash(:error, "Você precisa estar logado.")
         |> push_navigate(to: ~p"/login")}

      current_user.id != String.to_integer(id) ->
        {:ok,
         socket
         |> put_flash(:error, "Ei, nada de bisbilhotar a conta alheia!")
         |> push_navigate(to: ~p"/items")}

      true ->
        user = Auction.get_user(id)

        # 2. Agora buscamos os lances desse usuário
        bids = Auction.get_bids_for_user(user)

        {:ok,
         socket
         |> assign(:user, user)
         |> assign(:bids, bids)} # Guardamos no socket
    end
  end
end
