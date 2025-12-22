defmodule AuctionWeb.ItemLive.Show do
  use AuctionWeb, :live_view
  alias Auction

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    # 1. Buscamos o item específico usando o ID da URL
    item = Auction.get_item(id)

    # 2. Guardamos o item no socket
    {:ok, assign(socket, :item, item)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <h1><%= @item.title %></h1>
    <ul>
      <li><strong>Description:</strong> <%= @item.description %></li>
      <li><strong>Auction ends at:</strong> <%= @item.ends_at %></li>
    </ul>
    """
  end
end
