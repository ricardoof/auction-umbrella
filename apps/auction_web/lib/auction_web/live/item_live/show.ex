defmodule AuctionWeb.ItemLive.Show do
  use AuctionWeb, :live_view
  import AuctionWeb.Formatters
  alias Auction
  alias Auction.Bid # <--- 1. Precisamos desse alias novo

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    # 1. TRADUÇÃO DO LIVRO: Conectando ao tópico "item:123"
    # O "connected?(socket)" garante que só assinamos quando o WebSocket estiver ativo
    # (evita assinar duas vezes durante o carregamento inicial HTML)
    if connected?(socket) do
      Phoenix.PubSub.subscribe(AuctionWeb.PubSub, "item:#{id}")
    end

    item = Auction.get_item_with_bids(id)

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
    # Precisamos garantir que o item_id e user_id estejam nos params
    # O item está no socket, então pegamos o ID dele de lá
    updated_params =
      bid_params
      |> Map.put("item_id", socket.assigns.item.id)
      |> Map.put("user_id", socket.assigns.current_user.id)

    case Auction.create_bid(updated_params) do
      {:ok, bid} ->
        # 1. CORREÇÃO DO BID: Usamos 'bid' que veio do {:ok, bid}
        # Carregamos o user para poder mostrar o nome dele na tela (Hacker do Terminal, etc)
        bid = Auction.Repo.preload(bid, :user)

        # 2. CORREÇÃO DO ITEM: O item não é uma variável solta.
        # Ele está dentro do 'socket.assigns.item'.
        # Vamos pegar o ID direto do bid que acabamos de criar, é mais seguro.
        Phoenix.PubSub.broadcast(AuctionWeb.PubSub, "item:#{bid.item_id}", {:new_bid, bid})

        # Recarregamos o item inteiro para garantir a ordenação correta na tela de quem clicou
        item = Auction.get_item_with_bids(bid.item_id)

        # Criamos um novo changeset vazio para limpar o formulário
        changeset = Auction.change_bid(%Auction.Bid{})

        {:noreply,
         socket
         |> assign(:item, item)
         |> assign_form(changeset)
         |> put_flash(:info, "Lance realizado com sucesso!")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  # 5. Helper para converter Changeset em Form
  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  # Essa função roda AUTOMATICAMENTE quando chega uma mensagem no tópico assinado
  # 3. HANDLE_INFO: Simplificado
  def handle_info({:new_bid, bid}, socket) do
    current_item = socket.assigns.item

    # Verifica duplicata
    if Enum.any?(current_item.bids, &(&1.id == bid.id)) do
      {:noreply, socket}
    else
      # Como a lista atual já vem ordenada do banco, e o 'bid' é o mais novo de todos,
      # basta colocar ele na frente da lista ([bid | ...]).
      # Não precisa rodar sort_by na lista inteira de novo, economiza processamento!
      updated_bids = [bid | current_item.bids]

      updated_item = Map.put(current_item, :bids, updated_bids)
      {:noreply, assign(socket, :item, updated_item)}
    end
  end
end
