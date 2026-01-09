defmodule AuctionTest do
  # Traz o DataCase (Sandbox + Repo)
  use Auction.DataCase

  # Traz nossa Factory nova
  import Auction.Factory

  doctest Auction

  # --- Teste 1: list_items/0 ---
  describe "list_items/0" do
    test "returns all items in the database" do
      # Cria 3 itens usando a Factory (simples!)
      item1 = insert(:item)
      item2 = insert(:item)
      item3 = insert(:item)

      # Busca do banco
      items = Auction.list_items()

      # Verifica se os 3 estão lá
      assert length(items) == 3

      # Verifica se os IDs batem (ignorando a ordem)
      item_ids = Enum.map(items, & &1.id)
      assert item1.id in item_ids
      assert item2.id in item_ids
      assert item3.id in item_ids
    end
  end

  # --- Teste 2: get_item/1 ---
  describe "get_item/1" do
    test "returns a single item by id" do
      # Cria 2 itens
      item1 = insert(:item, title: "O Alvo")
      _item2 = insert(:item, title: "O Outro") # Ignoramos este

      # Busca só o item 1
      found_item = Auction.get_item(item1.id)

      # Garante que veio o item certo
      assert found_item.id == item1.id
      assert found_item.title == "O Alvo"
    end
  end

  # --- Teste 3: insert_item/1 ---
  describe "insert_item/1" do
    test "creates an item with valid attributes" do
      attrs = %{title: "Playstation 5", description: "Novo na caixa"}

      # Tenta inserir
      assert {:ok, item} = Auction.insert_item(attrs)

      # Verifica se os dados batem
      assert item.title == "Playstation 5"
      assert item.description == "Novo na caixa"
      assert item.id != nil # Tem ID gerado pelo banco
    end

    test "fails with invalid attributes" do
      # Tenta inserir sem título (deve falhar)
      assert {:error, changeset} = Auction.insert_item(%{title: nil})

      # Verifica se o erro é no título
      assert "can't be blank" in errors_on(changeset).title
    end
  end
end
