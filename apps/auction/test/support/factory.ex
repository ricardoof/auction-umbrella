defmodule Auction.Factory do
  alias Auction.{Repo, Item, User, Bid}

  # 1. Correção da DATA: Usamos DateTime (com fuso) em vez de NaiveDateTime
  def build(:item) do
    %Item{
      title: "Item Genérico #{System.unique_integer()}",
      description: "Uma descrição padrão para testes",
      # DateTime.utc_now() gera o tipo :utc_datetime correto para o Ecto
      ends_at: DateTime.utc_now()
               |> DateTime.add(3600, :second)
               |> DateTime.truncate(:second)
    }
  end

  def build(:user) do
    %User{
      username: "user_#{System.unique_integer()}",
      email_address: "user#{System.unique_integer()}@example.com",
      password: "password123"
    }
  end

  # 2. Correção do MAPA: Tornamos a função flexível
  def insert(type, attrs \\ %{}) do
    # Converte Keyword List ([title: "X"]) para Mapa (%{title: "X"}) se necessário
    attrs = Enum.into(attrs, %{})

    merged_attrs = Map.merge(build(type), attrs)
    Repo.insert!(merged_attrs)
  end
end
