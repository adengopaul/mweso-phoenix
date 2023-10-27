defmodule MwesoWeb.RoomChannel do
  use MwesoWeb, :channel

  def timer(start, 1) do
    timediff = Time.diff(Time.utc_now(), start)
  end

  def timer(start, time) do
    timediff = Time.diff(Time.utc_now(), start)
    timer(start, timediff)
  end

  @impl true
  def join("room:game", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:game).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  def ok do
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast!(socket, "new_msg", %{body: body})
    {:noreply, socket}
  end

  def handle_in("start", _payload, socket) do
    formation4x8 = false

    Agent.start_link(fn -> [] end, name: Player1)
    Agent.start_link(fn -> [] end, name: Player2)
    Agent.start_link(fn -> 0 end, name: Seeds1)
    Agent.start_link(fn -> 0 end, name: Seeds2)
    Agent.start_link(fn -> false end, name: Sowing)

    Enum.each(1..16, fn i ->
      if formation4x8 == true do
        cond do
          i <= 8 ->
            Agent.update(Player1, fn player1 ->
              [%{index: i - 1, ground: i, color: "bg-rose-500", seeds: 4} | player1]
            end)

            Agent.update(Player2, fn player2 ->
              [%{index: i - 1, ground: i, color: "bg-sky-500", seeds: 4} | player2]
            end)

          i >= 9 ->
            Agent.update(Player1, fn player1 ->
              [%{index: i - 1, ground: i, color: "bg-rose-500", seeds: 0} | player1]
            end)

            Agent.update(Player2, fn player2 ->
              [%{index: i - 1, ground: i, color: "bg-sky-500", seeds: 0} | player2]
            end)
        end
      else
        Agent.update(Player1, fn player1 ->
          [%{index: i - 1, ground: i, color: "bg-rose-500", seeds: 2} | player1]
        end)

        Agent.update(Player2, fn player2 ->
          [%{index: i - 1, ground: i, color: "bg-sky-500", seeds: 2} | player2]
        end)
      end
    end)

    Agent.update(Player1, fn player1 -> Enum.reverse(player1) end)
    Agent.update(Player2, fn player2 -> Enum.reverse(player2) end)

    player1 = Agent.get(Player1, fn player1 -> player1 end)
    player2 = Agent.get(Player2, fn player2 -> player2 end)

    # player1
    # |> Enum.at(0)
    # |> Jason.encode!()
    # |> IO.puts()

    # Agent.stop(Player1)

    push(socket, "view_update", %{player1: player1, player2: player2})
    {:noreply, socket}
  end

  def handle_in("ground_click", payload, socket) do
    # payload |> Jason.encode!() |> IO.puts()
    # payload["index"] || payload[:index] |> Jason.encode!() |> IO.puts()
    # payload[:index] |> Jason.encode!() |> IO.puts()
    index = payload["index"] || payload[:index]
    seeds = payload["seeds"] || payload[:seeds]

    ground =
      Agent.get(Player1, fn player1 ->
        Enum.at(player1, index)
      end)

    Agent.update(Seeds1, fn seeds1 -> seeds1 + seeds end)
    ground = Map.replace(ground, :seeds, 0)
    # ground |> Jason.encode!() |> IO.puts()

    Agent.update(Player1, fn player1 ->
      List.replace_at(player1, index, ground)
    end)

    player1 = Agent.get(Player1, fn player1 -> player1 end)
    player2 = Agent.get(Player2, fn player2 -> player2 end)

    # player1
    # |> Enum.at(0)
    # |> Jason.encode!()
    # |> IO.puts()

    Agent.update(Sowing, fn _sowing -> true end)
    push(socket, "update_game", %{player1: player1, player2: player2})

    cond do
      ground[:index] < 15 ->
        sow(Enum.at(player1, ground[:ground]), socket)

      ground[:index] == 15 ->
        sow(Enum.at(player1, 0), socket)
    end

    {:noreply, socket}
  end

  defp sow(ground, socket) do
    timer(Time.utc_now(), 0)

    sowFn(ground, socket)
  end

  defp sowFn(ground, socket) do
    ground_seeds = ground["seeds"] || ground[:seeds]

    ground_seeds = ground_seeds + 1
    ground = Map.replace(ground, :seeds, ground_seeds)
    # ground |> Jason.encode!() |> IO.puts()

    Agent.update(Player1, fn player ->
      List.replace_at(player, ground[:index], ground)
    end)

    Agent.update(Seeds1, fn seeds -> seeds - 1 end)

    playing_seeds = Agent.get(Seeds1, fn seeds -> seeds end)

    player1 = Agent.get(Player1, fn player1 -> player1 end)
    player2 = Agent.get(Player2, fn player2 -> player2 end)

    # player1
    # # |> Enum.at(0)
    # |> Jason.encode!()
    # |> IO.puts()

    push(socket, "update_game", %{player1: player1, player2: player2})
    {:noreply, socket}

    if playing_seeds == 0 do
      if ground_seeds > 1 do
        handle_in("ground_click", ground, socket)
      else
        Agent.update(Sowing, fn sowing -> false end)
      end
    else
      cond do
        ground[:index] < 15 ->
          sow(Enum.at(player1, ground[:ground]), socket)

        ground[:index] == 15 ->
          sow(Enum.at(player1, 0), socket)
      end
    end
  end
end
