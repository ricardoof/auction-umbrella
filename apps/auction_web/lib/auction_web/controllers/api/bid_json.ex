defmodule AuctionWeb.Api.BidJSON do
  alias Auction.Bid
  alias AuctionWeb.Api.UserJSON

  # --- Tratamento de Lista (Para has_many) ---

  # Se a lista de lances não foi carregada, retorna lista vazia
  def data_list(%Ecto.Association.NotLoaded{}), do: []

  # Se for uma lista real, formata cada item
  def data_list(bids) when is_list(bids) do
    for bid <- bids, do: data(bid)
  end

  # --- Tratamento Individual ---

  def data(%Bid{} = bid) do
    %{
      id: bid.id,
      amount: bid.amount,
      inserted_at: bid.inserted_at,
      # Agora chamamos direto, sem IF! O UserJSON se vira.
      user: UserJSON.data(bid.user)
    }
  end
end
