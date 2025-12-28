defmodule AuctionWeb.UserLive.Registration do
  use AuctionWeb, :live_view
  alias Auction
  alias Auction.User

  def mount(_params, _session, socket) do
    # Iniciamos o formulário com um usuário vazio
    changeset = Auction.change_user(%User{})

    {:ok, assign(socket, form: to_form(changeset), trigger_submit: false)}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm mt-10">
      <.header class="text-center">
        Registrar-se
        <:subtitle>
          Crie sua conta para começar a dar lances.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
      >
        <.input field={@form[:username]} type="text" label="Nome de Usuário" required />
        <.input field={@form[:email_address]} type="email" label="Email" required />

        <%!-- Note o type="password" aqui --%>
        <.input field={@form[:password]} type="password" label="Senha" required />
        <.input field={@form[:password_confirmation]} type="password" label="Confirmar Senha" required />

        <:actions>
          <.button phx-disable-with="Criando conta..." class="w-full">
            Criar Conta
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  # Validação em tempo real (para mostrar erros enquanto digita)
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      %User{}
      |> Auction.User.changeset_with_password(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  # Salvar no banco
  def handle_event("save", %{"user" => user_params}, socket) do
    case Auction.insert_user(user_params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Usuário criado com sucesso!")
         |> push_navigate(to: ~p"/users/#{user}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
