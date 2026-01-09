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

  @doc """
  Retrieves a user matching the given username and password.

  Returns `false` if no user is found or password doesn't match.

  ## Examples

      iex> # Setup: Agora com password_confirmation para passar na validação!
      iex> Auction.insert_user(%{
      ...>   username: "test_user",
      ...>   password: "secure_password",
      ...>   password_confirmation: "secure_password",
      ...>   email_address: "test@example.com"
      ...> })
      iex>
      iex> # Teste 1: Login com sucesso
      iex> user = Auction.get_user_by_username_and_password("test_user", "secure_password")
      iex> user.username
      "test_user"
      iex>
      iex> # Teste 2: Senha errada
      iex> Auction.get_user_by_username_and_password("test_user", "wrong_pass")
      false
      iex>
      iex> # Teste 3: Usuário inexistente
      iex> Auction.get_user_by_username_and_password("ghost", "123")
      false

  """
  def get_user_by_username_and_password(username, password) do
    with %User{} = user <- Repo.get_by(User, username: username),
         true <- Password.verify_with_hash(password, user.hashed_password) do
      user
    else
      _ ->
        Password.dummy_verify()
        false
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
    # Define a regra de ordenação: Lances ordenados por inserção (Descrescente)
    # E já faz o preload do usuário junto para não precisar carregar depois
    query_bids = from b in Auction.Bid,
      order_by: [desc: b.inserted_at],
      preload: [:user]

    id
    |> get_item()
    # Aqui dizemos: "Traga os lances usando aquela regra da query acima"
    |> Repo.preload(bids: query_bids)
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
