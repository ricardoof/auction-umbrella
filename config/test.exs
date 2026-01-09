import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :auction_web, AuctionWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "YMxkHs5qKCwu7KCY63iXAt8astumG3kKzr1mGBxiBq3e8q2ty7+NMgFFk5TDJBH8",
  server: false

  # Configuração do Banco de Testes
config :auction, Auction.Repo,
  username: "postgres",       # Se seu user for diferente, mude aqui
  password: "postgres",       # Se tiver senha, coloque aqui
  database: "auction_test",   # Nome do banco separado para testes
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox # <--- OBRIGATÓRIO: Ativa o modo Sandbox

# Silencia logs de SQL e Debug durante testes
config :logger, level: :warning
