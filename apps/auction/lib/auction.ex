defmodule Auction do
  import Ecto.Query
  alias Auction.{Repo, Item, User, Password, Bid}

  # --- ITENS ---
  def list_items, do: Repo.all(Item)

  def get_item(id), do: Repo.get!(Item, id)

  def get_item!(id), do: Repo.get!(Item, id)

  def get_item_by(attrs), do: Repo.get_by(Item, attrs)

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

  def change_item(%Item{} = item \\ %Item{}, attrs \\ %{}), do: Item.changeset(item, attrs)

  # --- USUÁRIOS (USER) ---
  def get_user(id), do: Repo.get!(User, id)

  def change_user(%User{} = user \\ %User{}, attrs \\ %{}), do: User.changeset_with_password(user, attrs)

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

  # Cria um changeset vazio ou com dados (substitui o new_bid do livro)
  def change_bid(%Bid{} = bid, attrs \\ %{}) do
    Bid.changeset(bid, attrs)
  end

  # Salva o lance no banco
  def create_bid(attrs) do
    %Bid{}
    |> Bid.changeset(attrs)
    |> Repo.insert()
  end

  # Traz o item, seus lances, e os donos dos lances
  def get_item_with_bids(id) do
    id
    |> get_item()
    |> Repo.preload(bids: [:user])
  end

  def get_bids_for_user(user) do
    from(b in Bid,
      where: b.user_id == ^user.id,
      order_by: [desc: :inserted_at], # Do mais novo para o mais antigo
      preload: :item,                # Precisamos dos dados do Item para mostrar o link
      limit: 10                      # Só os últimos 10
    )
    |> Repo.all()
  end
end
