defmodule AuctionWeb.Api.ItemJSON do
  alias Auction.Item
  alias AuctionWeb.Api.BidJSON

  # --- Ações do Controller (Entradas) ---

  def index(%{items: items}) do
    # Usa a nossa função segura data_list
    %{data: data_list(items)}
  end

  def show(%{item: item}) do
    # Usa a nossa função segura data
    %{data: data(item)}
  end

  # --- Funções "Blindadas" (Core) ---

  # 1. Caso: Lista de itens não carregada (Ex: User.items não preloaded)
  def data_list(%Ecto.Association.NotLoaded{}), do: []

  # 2. Caso: Lista real
  def data_list(items) when is_list(items) do
    for item <- items, do: data(item)
  end

  # 3. Caso: Item não carregado ou nil
  def data(%Ecto.Association.NotLoaded{}), do: nil
  def data(nil), do: nil

  # 4. Caso: O Item Real
  def data(%Item{} = item) do
    %{
      id: item.id,
      title: item.title,
      description: item.description,
      ends_at: item.ends_at,
      # Chama o BidJSON, que já é blindado e sabe lidar com listas ou NotLoaded
      bids: BidJSON.data_list(item.bids)
    }
  end
end
