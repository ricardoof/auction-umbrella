defmodule AuctionWeb.ItemLiveTest do
  use AuctionWeb.ConnCase

  import Phoenix.LiveViewTest
  alias Auction

  describe "Index Page (Lista de Itens)" do
    test "lists all items on the page", %{conn: conn} do
      {:ok, _item1} = Auction.insert_item(%{title: "Nintendo Switch"})
      {:ok, _item2} = Auction.insert_item(%{title: "Steam Deck"})

      {:ok, _index_live, html} = live(conn, ~p"/")

      assert html =~ "Nintendo Switch"
      assert html =~ "Steam Deck"
    end
  end

  describe "Saving a new Item" do
    test "creates new item via form", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/items/new")

      view
      |> form("#item-form", item: %{
        title: "Xbox Series X",
        description: "Console 4K",
        ends_at: DateTime.add(DateTime.utc_now(), 3600)
      })
      |> render_submit()

      {path, _flash} = assert_redirect(view)
      assert path =~ ~r"/items/\d+"

      items = Auction.list_items()
      last_item = List.last(items)
      assert last_item.title == "Xbox Series X"
    end

    # --- NOVO TESTE AQUI ---
    test "renders errors for invalid data", %{conn: conn} do
      # 1. Contamos quantos itens existem ANTES de tentar salvar
      before_count = length(Auction.list_items())

      {:ok, view, _html} = live(conn, ~p"/items/new")

      # 2. Tentamos salvar com erro (título vazio)
      html =
        view
        |> form("#item-form", item: %{title: ""})
        |> render_submit()

      assert html =~ "can&#39;t be blank"

      # 3. Verificamos se a contagem continua IGUAL (nada novo foi criado)
      assert length(Auction.list_items()) == before_count
    end
  end
end
