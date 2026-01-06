defmodule AuctionWeb.Api.ItemJSON do
  alias Auction.Item
  alias AuctionWeb.Api.BidJSON

  def index(%{items: items}) do
    %{data: for(item <- items, do: data(item))}
  end

  def show(%{item: item}) do
    %{data: data(item)}
  end

  def data(%Item{} = item) do
    %{
      id: item.id,
      title: item.title,
      description: item.description,
      ends_at: item.ends_at,
      # Olha que limpeza! O BidJSON que se vire pra saber se é lista ou NotLoaded
      bids: BidJSON.data_list(item.bids)
    }
  end
end
