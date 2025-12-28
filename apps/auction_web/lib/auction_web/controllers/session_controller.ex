defmodule AuctionWeb.SessionController do
  use AuctionWeb, :controller

  def create(conn, %{"user" => %{"username" => username, "password" => password}}) do
    case Auction.get_user_by_username_and_password(username, password) do
      %Auction.User{} = user ->
        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:info, "Login realizado com sucesso!")
        |> redirect(to: ~p"/users/#{user}")

      nil ->
        conn
        |> put_flash(:error, "Usuário ou senha inválidos.")
        |> redirect(to: ~p"/login")
    end
  end

  def delete(conn, _params) do
    conn
    |> clear_session()                   # Limpa os dados da sessão
    |> configure_session(drop: true)     # Remove o cookie do navegador
    |> put_flash(:info, "Você saiu do sistema.")
    |> redirect(to: ~p"/items")          # Redireciona para lista de itens
  end
end
