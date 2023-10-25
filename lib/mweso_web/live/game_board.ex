defmodule MwesoWeb.GameBoard do
  use MwesoWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="grid grid-rows-5 grid-flow-col gap-4 place-content-stretch">
      <div class="row-span-1 col-span-6 max-w-sm mx-auto flex items-center space-x-4">
        <div class="grow">
          <div class="text-xl font-medium text-black text-center">Omweso</div>
          
          <p class="text-slate-500">A centuries old game.</p>
        </div>
      </div>
      
      <div class="row-span-4 col-span-6 ">
        <div class="grid grid-rows-4 grid-cols-8 flex items-center">
          <!-- Player 2 -->
          <%= for index <- 7..0 do %>
            <.button :let={} class={"#{Enum.at(@player2, index).color} #{@button_size}"}>
              <%= Enum.at(@player2, index).seeds %>
            </.button>
          <% end %>
          
          <%= for index <- 8..15 do %>
            <.button class={"#{Enum.at(@player2, index).color} #{@button_size}"}>
              <%= Enum.at(@player2, index).seeds %>
            </.button>
          <% end %>
          <!-- Player 1 -->
          <%= for index <- 15..8 do %>
            <.button
              phx-click="click"
              phx-value-index={index}
              phx-value-player={:player1}
              class={"#{Enum.at(@player1, index).color} #{@button_size}"}
            >
              <%= Enum.at(@player1, index).seeds %>
            </.button>
          <% end %>
          
          <%= for index <- 0..7 do %>
            <.button
              phx-click="click"
              phx-value-index={index}
              phx-value-player={:player1}
              class={"#{Enum.at(@player1, index).color} #{@button_size}"}
            >
              <%= Enum.at(@player1, index).seeds %>
            </.button>
          <% end %>
          
          <div class="">Footer</div>
        </div>
      </div>
      <!-- <div class="row-span-1 col-span-6 ">Footer</div> -->
    </div>
    """
  end

  def mount(_params, _session, socket) do
    formation4x8 = false

    Agent.start_link(fn -> [] end, name: Agent1)
    Agent.start_link(fn -> [] end, name: Agent2)

    Enum.each(1..16, fn i ->
      if formation4x8 == true do
        cond do
          i <= 8 ->
            Agent.update(Agent1, fn player1 ->
              [%{ground: i, color: "bg-rose-500", seeds: 4} | player1]
            end)

            Agent.update(Agent2, fn player2 ->
              [%{ground: i, color: "bg-sky-500", seeds: 4} | player2]
            end)

          i >= 9 ->
            Agent.update(Agent1, fn player1 ->
              [%{ground: i, color: "bg-rose-500", seeds: 0} | player1]
            end)

            Agent.update(Agent2, fn player2 ->
              [%{ground: i, color: "bg-sky-500", seeds: 0} | player2]
            end)
        end
      else
        Agent.update(Agent1, fn player1 ->
          [%{ground: i, color: "bg-rose-#{:rand.uniform(9)}00", seeds: 2} | player1]
        end)

        Agent.update(Agent2, fn player2 ->
          [%{ground: i, color: "bg-sky-500", seeds: 2} | player2]
        end)
      end
    end)

    Agent.update(Agent1, fn player1 -> Enum.reverse(player1) end)
    Agent.update(Agent2, fn player2 -> Enum.reverse(player2) end)

    player1 = Agent.get(Agent1, fn player1 -> player1 end)
    player2 = Agent.get(Agent2, fn player2 -> player2 end)

    # player1
    # |> Enum.at(0)
    # |> Jason.encode!()
    # |> IO.puts()

    # Agent.stop(Agent1)
    button_size = "w-full h-full"

    {:ok, assign(socket, player1: player1, player2: player2, button_size: button_size)}
  end

  def handle_event("click", params, socket) do
    # params |> Jason.encode!() |> IO.puts()

    ground =
      Agent.get(Agent1, fn player1 -> Enum.at(player1, String.to_integer(params["index"])) end)

    ground = Map.replace(ground, :seeds, 0)
    # ground |> Jason.encode!() |> IO.puts()

    Agent.update(Agent1, fn player1 ->
      List.replace_at(player1, String.to_integer(params["index"]), ground)
    end)

    player1 = Agent.get(Agent1, fn player1 -> player1 end)
    # player1 |> Jason.encode!() |> IO.puts()
    # Process.send(self(), player1)
    {:noreply, assign(socket, player1: player1)}
    # {:reply, %{player1: player1}, socket}
  end
end
