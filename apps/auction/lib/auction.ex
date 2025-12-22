defmodule Auction do
  alias Auction.Item
  alias Auction.Repo

  def list_items do
    Repo.all(Item)
  end

  def get_item(id) do
    Repo.get!(Item, id)
  end

  def get_item_by(attrs) do
    Repo.get_by(Item, attrs)
  end

  def insert_item(attrs) do
    Auction.Item
    |> struct(attrs)
    |> Repo.insert()
  end

  # Atualiza um item existente
  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end


  def delete_item(%Auction.Item{} = item), do: Repo.delete(item)

  def create_item(attrs) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  # Busca um item pelo ID ou lança erro se não achar (importante para editar)
  def get_item!(id), do: Repo.get!(Item, id)

  def change_item(%Item{} = item \\ %Item{}, attrs \\ %{}) do
    Item.changeset(item, attrs)
  end
end
