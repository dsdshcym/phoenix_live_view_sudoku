defmodule SudokuWeb.PageController do
  use SudokuWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: "/demo")
  end
end
