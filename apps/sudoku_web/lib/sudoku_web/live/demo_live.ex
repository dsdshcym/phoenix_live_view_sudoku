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
    sudoku = %{}

    {:ok, server} = Sudoku.start_link(self())

    {:ok, assign(socket, sudoku: sudoku, server: server, solving: false, highlight_pos: nil)}
  end

  def handle_event("start_solving", %{"input" => input}, socket) do
    sudoku =
      for {row_str, num_strs_by_col_str} <- input,
          {col_str, num_str} <- num_strs_by_col_str,
          row = String.to_integer(row_str),
          col = String.to_integer(col_str),
          num = String.to_integer(num_str),
          num != 0,
          into: %{} do
        {{row, col}, num}
      end

    Sudoku.start_solving(socket.assigns.server, sudoku)

    {:noreply, assign(socket, solving: true)}
  end

  def handle_info({"update", new_sudoku, pos}, socket) do
    {:noreply, assign(socket, sudoku: new_sudoku, highlight_pos: pos)}
  end
end
