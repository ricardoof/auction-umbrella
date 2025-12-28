defmodule AuctionWeb.UserLive.Show do
  use AuctionWeb, :live_view
  alias Auction

  def mount(%{"id" => id}, _session, socket) do
    # Pegamos o usuário logado que o Hook de autenticação já colocou no socket
    current_user = socket.assigns.current_user

    # Regra de Negócio: Só mostre a página se o usuário for dono do perfil
    cond do
      # 1. Se não estiver logado -> Manda pro Login
      is_nil(current_user) ->
        {:ok,
         socket
         |> put_flash(:error, "Você precisa estar logado.")
         |> push_navigate(to: ~p"/login")}

      # 2. Se estiver logado, mas o ID não bate -> Bloqueia (Regra do Livro)
      # Nota: Precisamos converter o ID da URL (string) para Inteiro para comparar
      current_user.id != String.to_integer(id) ->
        {:ok,
         socket
         |> put_flash(:error, "Ei, nada de bisbilhotar a conta alheia!")
         |> push_navigate(to: ~p"/items")}

      # 3. Se passou nas regras -> Mostra a página
      true ->
        user = Auction.get_user(id)
        {:ok, assign(socket, :user, user)}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-2xl mt-10">
      <.header>
        Detalhes do Usuário
        <:subtitle>Informações da sua conta.</:subtitle>
      </.header>

      <dl class="mt-6 divide-y divide-zinc-100 border-t border-zinc-200 text-sm leading-6">

        <div class="flex gap-4 py-3 sm:gap-8">
          <dt class="w-1/4 flex-none font-medium text-zinc-900">Username</dt>
          <dd class="text-zinc-700"><%= @user.username %></dd>
        </div>

        <div class="flex gap-4 py-3 sm:gap-8">
          <dt class="w-1/4 flex-none font-medium text-zinc-900">Email</dt>
          <dd class="text-zinc-700"><%= @user.email_address %></dd>
        </div>

      </dl>

      <div class="mt-8">
        <.link navigate={~p"/items"} class="text-blue-600 hover:underline">
          &larr; Voltar para Itens
        </.link>
      </div>
    </div>
    """
  end
end
