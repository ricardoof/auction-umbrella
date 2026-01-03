defmodule AuctionWeb.ItemLive.Show do
  use AuctionWeb, :live_view
  import AuctionWeb.Formatters
  alias Auction
  alias Auction.Bid # <--- 1. Precisamos desse alias novo

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    item = Auction.get_item_with_bids(id)

    # Ordenamos os lances para o mais recente aparecer primeiro (Opcional, mas recomendado)
    # O Ecto traz na ordem de inserção, mas na tela queremos o último lance no topo
    item = Map.update!(item, :bids, fn bids ->
      Enum.sort_by(bids, & &1.inserted_at, {:desc, Date})
    end)

    # 2. Preparamos um lance vazio para o formulário
    changeset = Auction.change_bid(%Bid{})

    {:ok,
     socket
     |> assign(:item, item)
     |> assign_form(changeset)} # <--- 3. Transformamos o changeset em formulário
  end

  # 4. Recebemos o evento de salvar o formulário
  @impl true
  def handle_event("save_bid", %{"bid" => bid_params}, socket) do
    # Pegamos os IDs necessários
    item_id = socket.assigns.item.id
    user_id = socket.assigns.current_user.id

    # Combinamos os dados do formulário com os IDs
    params = Map.merge(bid_params, %{"item_id" => item_id, "user_id" => user_id})

    case Auction.create_bid(params) do
      {:ok, _bid} ->
        # 1. Buscamos o item COMPLETO (com lances e usuários)
        item = Auction.get_item_with_bids(item_id)

        # 2. Reordenamos para o mais novo ficar no topo (igual no mount)
        item = Map.update!(item, :bids, fn bids ->
          Enum.sort_by(bids, & &1.inserted_at, {:desc, Date})
        end)

        changeset = Auction.change_bid(%Bid{})

        {:noreply,
         socket
         |> assign(:item, item)
         |> assign_form(changeset)
         |> put_flash(:info, "Lance realizado com sucesso!")}

      {:error, %Ecto.Changeset{} = changeset} ->
        # Erro: Devolve o formulário com as mensagens de erro (vermelhas)
        {:noreply, assign_form(socket, changeset)}
    end
  end

  # 5. Helper para converter Changeset em Form
  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
