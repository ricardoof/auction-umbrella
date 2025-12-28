defmodule Auction do
  alias Auction.{Repo, Item, User, Password}

  # --- ITENS ---

  def list_items do
    Repo.all(Item)
  end

  def get_item(id) do
    Repo.get!(Item, id)
  end

  def get_item!(id), do: Repo.get!(Item, id)

  def get_item_by(attrs) do
    Repo.get_by(Item, attrs)
  end

  def insert_item(attrs) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  def delete_item(%Item{} = item), do: Repo.delete(item)

  def create_item(attrs) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  def change_item(%Item{} = item \\ %Item{}, attrs \\ %{}) do
    Item.changeset(item, attrs)
  end

  # --- USUÁRIOS (USER) ---

  def get_user(id), do: Repo.get!(User, id)

  # Adicione esta função para o formulário de registro funcionar
  def change_user(%User{} = user \\ %User{}, attrs \\ %{}) do
    User.changeset_with_password(user, attrs)
  end

  def insert_user(params) do
    %User{}
    |> User.changeset_with_password(params)
    |> Repo.insert()
  end

  # Tenta achar usuário e conferir senha
  def get_user_by_username_and_password(username, password) do
    with %User{} = user <- Repo.get_by(User, username: username),
         true <- Password.verify_with_hash(password, user.hashed_password) do
      user
    else
      _ ->
        Password.dummy_verify()
        nil
    end
  end
end
