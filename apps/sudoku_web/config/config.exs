# Since configuration is shared in umbrella projects, this file
# should only configure the :sudoku_web application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

# General application configuration
config :sudoku_web,
  generators: [context_app: :sudoku]

# Configures the endpoint
config :sudoku_web, SudokuWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "O4X3Pf6a3DfZYmrNTObEV/MatKBHOC0PsqtCxPOwOR4HqamUXx+sL5ujC/qNenOl",
  render_errors: [view: SudokuWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: SudokuWeb.PubSub, adapter: Phoenix.PubSub.PG2]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
