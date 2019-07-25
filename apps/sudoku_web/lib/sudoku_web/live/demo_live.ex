defmodule SudokuWeb.DemoLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <form phx-submit="start_solving">
      <div class="sudoku">
      <%= for i <- 0..8 do %>
        <div>
          <%= for j <- 0..8 do %>
            <input maxlength="1" size="1" name="input[<%= i %>][<%= j %>]" value="<%= Map.get(@sudoku, {i, j}, 0) %>"
              class="<%= if {i, j} == @highlight_pos, do: "highlight" %>"
              <%= if @solving, do: "disabled" %>/>
          <% end %>
        </div>
      <% end %>
      </div>

      <button>Start</button>
    </form>
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

    {:ok, assign(socket, sudoku: sudoku, server: server, solving: false, highlight_pos: nil)}
  end

  def handle_event("start_solving", _value, socket) do
    sudoku = socket.assigns.sudoku

    Sudoku.start_solving(socket.assigns.server, sudoku)

    {:noreply, assign(socket, solving: true)}
  end

  def handle_info({"update", new_sudoku, pos}, socket) do
    {:noreply, assign(socket, sudoku: new_sudoku, highlight_pos: pos)}
  end
end
