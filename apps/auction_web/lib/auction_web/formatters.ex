defmodule AuctionWeb.Formatters do
  # 1. Trazendo a função de moeda que corrigimos antes
  def format_currency(nil), do: "R$ 0,00"
  def format_currency(cents) do
    valor_decimal =
      Decimal.new(cents)
      |> Decimal.div(100)
      |> Decimal.round(2)

    valor_string = :erlang.float_to_binary(Decimal.to_float(valor_decimal), [decimals: 2])
    "R$ " <> String.replace(valor_string, ".", ",")
  end

  # 2. Formatação de Data NATIVA (Sem Timex)
  # Formato: 03/01/2026 14:30
  def format_datetime(nil), do: ""
  def format_datetime(datetime) do
    # Calendar.strftime já vem no Elixir!
    Calendar.strftime(datetime, "%d/%m/%Y %H:%M")
  end
end
