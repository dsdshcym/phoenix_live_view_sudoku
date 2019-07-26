defmodule Sudoku do
  use GenServer

  def start_link(pid) do
    GenServer.start_link(__MODULE__, pid)
  end

  def start_solving(server, sudoku) do
    GenServer.cast(server, {:start_solving, sudoku})
  end

  def next(server) do
    GenServer.call(server, :next)
  end

  @impl true
  def init(pid) do
    {:ok, %{live_pid: pid}}
  end

  def solve(input) when is_list(input) do
    input
    |> Sudoku.to_map()
    |> Sudoku.solve()
    |> Sudoku.to_list()
  end

  def solve(input) when is_map(input) do
    case for i <- 0..8, j <- 0..8, pos = {i, j}, !Map.has_key?(input, pos), do: pos do
      [] ->
        input

      empty_positions ->
        [{least_posible_position, posibilities} | _] =
          empty_positions
          |> Enum.map(&{&1, all_posibilities(input, &1)})
          |> Enum.sort_by(fn {_pos, posibilities} -> length(posibilities) end)

        posibilities
        |> Stream.map(&solve(Map.put(input, least_posible_position, &1)))
        |> Stream.reject(fn result -> result == :error end)
        |> Stream.take(1)
        |> Enum.to_list()
        |> case do
          [] -> :error
          [result] -> result
        end
    end
  end

  def handle_cast({:start_solving, sudoku}, status) do
    {:noreply, Map.put(status, :stack, [{nil, sudoku}])}
  end

  def handle_call(:next, _from, %{live_pid: pid, stack: [{pos, input} | rest]} = status) do
    case for i <- 0..8, j <- 0..8, pos = {i, j}, !Map.has_key?(input, pos), do: pos do
      [] ->
        {:reply, {input, pos}, status}

      empty_positions ->
        [{least_posible_position, posibilities} | _] =
          empty_positions
          |> Enum.map(&{&1, all_posibilities(input, &1)})
          |> Enum.sort_by(fn {_pos, posibilities} -> length(posibilities) end)

        new_stack =
          posibilities
          |> Enum.map(&Map.put(input, least_posible_position, &1))
          |> Enum.reduce(rest, &[{least_posible_position, &1} | &2])

        {:reply, {input, pos}, %{status | stack: new_stack}}
    end
  end

  def solve(input, pid) do
    case for i <- 0..8, j <- 0..8, pos = {i, j}, !Map.has_key?(input, pos), do: pos do
      [] ->
        input

      empty_positions ->
        [{least_posible_position, posibilities} | _] =
          empty_positions
          |> Enum.map(&{&1, all_posibilities(input, &1)})
          |> Enum.sort_by(fn {_pos, posibilities} -> length(posibilities) end)

        posibilities
        |> Stream.map(fn posibility ->
          new_soduku = Map.put(input, least_posible_position, posibility)

          send(pid, {"update", new_soduku, least_posible_position})
          Process.sleep(1000)

          solve(new_soduku, pid)
        end)
        |> Stream.reject(fn result -> result == :error end)
        |> Stream.take(1)
        |> Enum.to_list()
        |> case do
          [] -> :error
          [result] -> result
        end
    end
  end

  def all_posibilities(map, {i, j}) do
    same_row = for jj <- 0..8, do: Map.get(map, {i, jj})
    same_column = for ii <- 0..8, do: Map.get(map, {ii, j})

    block_i = div(i, 3)
    block_j = div(j, 3)

    same_block =
      for ii <- (block_i * 3)..(block_i * 3 + 2),
          jj <- (block_j * 3)..(block_j * 3 + 2),
          do: Map.get(map, {ii, jj})

    Enum.shuffle(
      Enum.to_list(1..9) --
        ((same_row ++ same_column ++ same_block)
         |> Enum.uniq()
         |> Enum.reject(&(&1 == nil)))
    )
  end

  def to_map(list) do
    for {row, i} <- Enum.with_index(list),
        {num, j} <- Enum.with_index(row),
        num != 0,
        into: %{},
        do: {{i, j}, num}
  end

  def to_list(map) do
    for i <- 0..8 do
      for j <- 0..8 do
        Map.get(map, {i, j}, 0)
      end
    end
  end
end
