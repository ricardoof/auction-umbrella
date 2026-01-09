defmodule Auction.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Auction.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Auction.DataCase
    end
  end

  setup tags do
    # Garante que o banco seja limpo antes deste teste rodar
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Auction.Repo)

    # Se o teste não for assíncrono, definimos o modo compartilhado
    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Auction.Repo, {:shared, self()})
    end

    :ok
  end

  @doc """
  A helper that transforms changeset errors into a map of messages.
  Ajuda a verificar erros em testes: assert errors_on(changeset).password == ["can't be blank"]
  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
