defmodule AuctionWeb.ItemLive.Index do
  use AuctionWeb, :live_view
  alias Auction
  alias Auction.Item

  @impl true
  def mount(_params, _session, socket) do
    # 1. Procuramos os itens no banco de dados (através da nossa interface Auction)
    items = Auction.list_items()

    # 2. Guardamos os itens no "socket" para que o HTML possa aceder
    {:ok, assign(socket, :items, items)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Novo Item")
    |> assign(:item, %Item{})
    |> assign(:form, to_form(Auction.change_item(%Item{})))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listagem de Itens")
    |> assign(:item, nil)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    item = Auction.get_item!(id)

    socket
    |> assign(:page_title, "Editar Item")
    |> assign(:item, item)
    |> assign(:form, to_form(Auction.change_item(item)))
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-4">
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-2xl font-bold">Listagem de Itens</h1>

        <.link patch={~p"/items/new"}>
          <button class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
            Novo Item
          </button>
        </.link>
      </div>

      <ul class="space-y-3">
        <%= for item <- @items do %>
          <li class="border p-3 rounded shadow-sm hover:shadow-md transition flex justify-between items-center">
            <div>
              <strong>
                <.link navigate={~p"/items/#{item}"} class="text-blue-600 hover:underline">
                  <%= item.title %>
                </.link>
              </strong>
              <p class="text-gray-600"><%= item.description %></p>
            </div>

            <.link patch={~p"/items/#{item}/edit"} class="text-sm text-yellow-600 hover:text-yellow-800 font-bold border px-2 py-1 rounded">
              Editar
            </.link>
          </li>
        <% end %>
      </ul>

      <.modal
        :if={@live_action in [:new, :edit]}
        id="new-item-modal"
        show
        on_cancel={JS.patch(~p"/items")}
      >
        <.header>
          <span class="text-zinc-900"><%= @page_title %></span>

          <:subtitle>
            <span class="text-zinc-500">
              Use o formulário abaixo para gerenciar o item.
            </span>
          </:subtitle>
        </.header>

        <.simple_form
          for={@form}
          id="item-form"
          phx-change="validate"
          phx-submit="save"
        >
          <.input field={@form[:title]} type="text" label="Título" />
          <.input field={@form[:description]} type="textarea" label="Descrição" />
          <.input field={@form[:ends_at]} type="datetime-local" label="O leilão termina em" />

          <:actions>
            <.button phx-disable-with="Salvando...">Salvar Item</.button>
          </:actions>
        </.simple_form>
      </.modal>
    </div>
    """
  end

  # 1. VALIDAÇÃO (Corrige o texto sumindo)
  # Toda vez que você digita uma letra, essa função é chamada.
  # Ela atualiza o changeset no socket, mantendo o que você digitou na tela.
  @impl true
  def handle_event("validate", %{"item" => item_params}, socket) do
    changeset =
      socket.assigns.item
      |> Auction.change_item(item_params)
      |> Map.put(:action, :validate) # Sinaliza que é apenas uma validação, não um salvamento

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"item" => item_params}, socket) do
    save_item(socket, socket.assigns.live_action, item_params)
  end

  defp save_item(socket, :new, item_params) do
    case Auction.create_item(item_params) do
      {:ok, item} ->
        {:noreply,
         socket
         |> put_flash(:info, "Item criado com sucesso!")
         |> push_navigate(to: ~p"/items/#{item}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp save_item(socket, :edit, item_params) do
    # socket.assigns.item contém o item que buscamos no apply_action
    case Auction.update_item(socket.assigns.item, item_params) do
      {:ok, item} ->
        {:noreply,
         socket
         |> put_flash(:info, "Item atualizado com sucesso!")
         |> push_navigate(to: ~p"/items/#{item}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end
