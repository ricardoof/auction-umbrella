defmodule AuctionWeb.Api.UserJSON do
  alias Auction.User

  # 1. Caso: A associação NÃO foi carregada no Ecto
  def data(%Ecto.Association.NotLoaded{}), do: nil

  # 2. Caso: O usuário é nil (ex: um lance sem usuário, se fosse possível)
  def data(nil), do: nil

  # 3. Caso: O usuário existe e é uma struct válida
  def data(%User{} = user) do
    %{
      id: user.id,
      username: user.username
    }
  end
end
