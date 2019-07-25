defmodule SudokuWeb.PageController do
  use SudokuWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
