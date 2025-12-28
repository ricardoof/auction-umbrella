defmodule AuctionWeb.UserLive.Login do
  use AuctionWeb, :live_view

  def mount(_params, _session, socket) do
    email = live_flash(socket.assigns.flash, :email)
    form = to_form(%{"username" => email}, as: "user")
    {:ok, assign(socket, form: form)}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm mt-10">
      <.header class="text-center">
        Entrar no Sistema
        <:subtitle>Faça login para gerenciar seus leilões.</:subtitle>
      </.header>

      <%!--
        ATENÇÃO AQUI:
        1. action={~p"/login"}: Manda para o Controller, não para o LiveView via socket
        2. method="post": Força requisição HTTP clássica
      --%>
      <.simple_form
        for={@form}
        id="login_form"
        action={~p"/login"}
        method="post"
        as="user"
      >
        <.input field={@form[:username]} type="text" label="Username" required />
        <.input field={@form[:password]} type="password" label="Senha" required />

        <:actions>
          <.button phx-disable-with="Entrando..." class="w-full">
            Entrar
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end
end
