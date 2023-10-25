defmodule MwesoWeb.GameController do
  use MwesoWeb, :controller

  @button_size "w-full h-full"
  def start(player, 16) do
    player = [%{color: "bg-rose-500", seeds: 2} | player]

    player
    |> Jason.encode!()
    |> IO.puts()
  end

  def start(player, i) do
    start(player, i + 1)
    player = [%{color: "bg-rose-500", seeds: 2} | player]

    player
    |> Jason.encode!()
    |> IO.puts()
  end

  def index(conn, _params) do
    # player1 = []
    # player2 = {}
    # seeds = {0, 0}
    #  gameState = %{'player1': {}, 'player2': {}}
    formation4x8 = true

    # player1_seeds = {4, 4, 4}

    {:ok, agent1} = Agent.start_link(fn -> [] end)
    {:ok, agent2} = Agent.start_link(fn -> [] end)
    # Agent.update(agent, fn list -> ["eggs" | list] end)
    # list = Agent.get(agent, fn list -> list end)
    # list
    # |> Jason.encode!()
    # |> IO.puts()
    # Agent.stop(agent)


    Enum.each(1..16, fn i ->
      if formation4x8 do
        cond do
          i <= 8 ->
            Agent.update(agent1, fn player1 ->
              [%{ground: i, color: "bg-rose-500", seeds: 4} | player1]
            end)

            Agent.update(agent2, fn player2 ->
              [%{ground: i, color: "bg-sky-#{:rand.uniform(9)}00", seeds: 4} | player2]
            end)

          i >= 9 ->
            Agent.update(agent1, fn player1 ->
              [%{ground: i, color: "bg-rose-#{:rand.uniform(9)}00", seeds: 0} | player1]
            end)

            Agent.update(agent2, fn player2 ->
              [%{ground: i, color: "bg-sky-#{:rand.uniform(9)}00", seeds: 0} | player2]
            end)
        end
      else
        Agent.update(agent1, fn player1 ->
          [%{ground: i, color: "bg-rose-#{:rand.uniform(9)}00", seeds: 2} | player1]
        end)

        Agent.update(agent2, fn player2 ->
          [%{ground: i, color: "bg-sky-#{:rand.uniform(9)}00", seeds: 2} | player2]
        end)
      end
    end)

    player1 = Enum.reverse(Agent.get(agent1, fn player1 -> player1 end))
    player2 = Enum.reverse(Agent.get(agent2, fn player2 -> player2 end))

    Agent.update(agent1, fn player1 -> player1 end)
    Agent.update(agent2, fn player2 -> player2 end)

    # player1
    # |> Enum.at(0)
    # |> Jason.encode!()
    # |> IO.puts()

    # Agent.stop(agent1)
    render(conn, :index, player1: player1, player2: player2, button_size: @button_size)
  end
end
