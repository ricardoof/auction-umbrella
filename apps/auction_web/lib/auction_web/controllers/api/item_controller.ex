defmodule AuctionWeb.Api.ItemController do
  use AuctionWeb, :controller
  alias Auction

  def index(conn, _params) do
    items = Auction.list_items()
    # No Phoenix moderno, chamamos o render assim:
    render(conn, :index, items: items)
  end

  def show(conn, %{"id" => id}) do
    # Usamos aquela função poderosa que já faz preload de bids e user
    item = Auction.get_item_with_bids(id)
    render(conn, :show, item: item)
  end
end
