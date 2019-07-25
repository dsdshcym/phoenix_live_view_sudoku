defmodule SudokuWeb.DemoLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div>
    <%= for row <- @sudoku do %>
      <div>
        <%= inspect(row) %>
      </div>
    <% end %>
    </div>

    <div>
    <button phx-click="start_solving">Start</button>
    </div>
    """
  end

  def mount(_session, socket) do
    sudoku = [
      [2, 8, 3, 1, 0, 0, 0, 0, 7],
      [7, 0, 0, 0, 0, 0, 0, 4, 0],
      [4, 0, 0, 0, 0, 0, 2, 0, 3],
      [6, 3, 0, 2, 0, 0, 7, 0, 0],
      [0, 5, 0, 0, 6, 3, 4, 0, 9],
      [0, 0, 7, 5, 0, 4, 0, 3, 8],
      [3, 1, 0, 0, 2, 0, 8, 7, 5],
      [5, 7, 0, 0, 0, 1, 9, 0, 4],
      [0, 4, 9, 6, 7, 5, 3, 1, 0]
    ]

    {:ok, assign(socket, sudoku: sudoku)}
  end

  def handle_event("start_solving", _value, socket) do
    socket.assigns.sudoku
    |> Sudoku.to_map()
    |> Sudoku.solve(self())

    {:noreply, socket}
  end

  def handle_info({"update", new_sudoku}, socket) do
    {:noreply, assign(socket, sudoku: new_sudoku)}
  end
end
