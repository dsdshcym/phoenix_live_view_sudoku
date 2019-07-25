defmodule SudokuWeb.DemoLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div class="sudoku">
    <%= for i <- 0..8 do %>
      <div>
        <%= for j <- 0..8 do %>
          <%= Map.get(@sudoku, {i, j}, 0) %>
        <% end %>
      </div>
    <% end %>
    </div>

    <div>
    <button phx-click="start_solving">Start</button>
    </div>
    """
  end

  def mount(_session, socket) do
    sudoku =
      [
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
      |> Sudoku.to_map()

    {:ok, server} = Sudoku.start_link(self())

    {:ok, assign(socket, sudoku: sudoku, server: server)}
  end

  def handle_event("start_solving", _value, socket) do
    sudoku = socket.assigns.sudoku

    Sudoku.start_solving(socket.assigns.server, sudoku)

    {:noreply, socket}
  end

  def handle_info({"update", new_sudoku}, socket) do
    {:noreply, assign(socket, sudoku: new_sudoku)}
  end
end
