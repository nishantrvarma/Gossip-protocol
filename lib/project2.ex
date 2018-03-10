defmodule PROJECT2 do
  def main(args) do
    pid = self()          # gets main process pid
    :global.register_name(:final,pid) #registers main process pid as global
    args |> startNode
    b = :os.system_time(:millisecond)
    receive do
      {:stop} ->
          IO.puts "done"
          IO.puts :os.system_time(:millisecond) - b
    end
  end

  def receiver(numb) do
    receive do
      {:ok, "hello"} ->
        IO.puts "received"

        numb = numb-1
        if numb==0 do
          final = :global.whereis_name(:final)    #finds main process pid
          send final, {:stop}                     #sends message to main process when numb = 0
        end
      receiver(numb)
    end
  end

  def networkFormation(args) do
    algorithm = Enum.at(args, 2)
    topology = Enum.at(args, 1)
    numNodes = String.to_integer(Enum.at(args, 0))
    if topology == "2D"  || topology == "imp2D" do
      root = :math.sqrt(numNodes)
      ceiling = :math.ceil(root)
      numNodes = :math.pow(ceiling, 2) |> round
    end
    createActors(1, numNodes, topology, algorithm, numNodes)
    if algorithm == "gossip" do
      GenServer.cast(:actor1, {:node, :"actor1"})
    end
    if algorithm == "push-sum" do
      GenServer.cast(:actor1, {:node2, :"actor1", 0, 0})
    end
    receiver_pid = spawn(PROJECT2, :receiver,[numNodes])  # starts receiver process
    :global.register_name(:final_2,receiver_pid)          #sets global name for receiver process
  end

  def createActors(index, numNodes, topology, algorithm, totalActors) do
    if numNodes>0 do
      actorName = :"actor#{index}"
      list = []
      list = createNeighborList(index, topology, totalActors, list)
      Supervisora.add_actors(actorName, list, 0, index, 1)
      createActors(index+1, numNodes-1, topology, algorithm, totalActors)
    end
  end

  def createNeighborList(index, topology, totalActors, list) do
    cond do
      topology == "full" -> fullTopology(index, totalActors, list)
      topology == "2D" -> twoDTopology(index, totalActors, list)
      topology == "line" -> lineTopology(index, totalActors, list)
      topology =="imp2D" -> imp2DTopology(index, totalActors, list)
    end
  end

  def fullTopology(index, totalActors, list) do
    random_number = :rand.uniform(totalActors)
    list = 1..totalActors |> Enum.to_list
    list
  end

  def twoDTopology(index, totalActors, list) do
    rows = :math.sqrt(totalActors) |> round
    if rem(index, rows) == 0 do
      cond do
        index == rows ->
          list = List.insert_at(list, 0, index-1)
          list = List.insert_at(list, 1, index+rows)
        index == totalActors ->
          list = List.insert_at(list, 0, index-1)
          list = List.insert_at(list, 1, index-rows)
        index != rows && index != totalActors ->
          list = List.insert_at(list, 0, index-1)
          list = List.insert_at(list, 1, index-rows)
          list = List.insert_at(list, 2, index+rows)
      end
    end

    if rem(index, rows) == 1 do
      cond do
        index == 1 ->
          list = List.insert_at(list, 0, index+1)
          list = List.insert_at(list, 1, index+rows)
        index == totalActors-rows+1 ->
          list = List.insert_at(list, 0, index+1)
          list = List.insert_at(list, 1, index-rows)
        index != 1 && index != totalActors-rows+1 ->
          list = List.insert_at(list, 0, index+1)
          list = List.insert_at(list, 1, index-rows)
          list = List.insert_at(list, 2, index+rows)
      end
    end

    if index<rows && index>1 do
      list = List.insert_at(list, 0, index-1)
      list = List.insert_at(list, 1, index+1)
      list = List.insert_at(list, 2, index+rows)
    end

    if index<totalActors && index>totalActors-rows+1 do
      list = List.insert_at(list, 0, index-1)
      list = List.insert_at(list, 1, index+1)
      list = List.insert_at(list, 2, index-rows)
    end

    if rem(index, rows) != 0 && rem(index, rows) != 1 && index>rows && index<totalActors-rows+1 do
      list = List.insert_at(list, 0, index-1)
      list = List.insert_at(list, 1, index+1)
      list = List.insert_at(list, 2, index-rows)
      list = List.insert_at(list, 3, index+rows)
    end
    list
  end

  def lineTopology(index, totalActors, list) do
    cond do
      index==1 -> list = List.insert_at(list, 0, 2)
      index==totalActors -> list = List.insert_at(list, 0, totalActors-1)
      index>1 ->
        list = List.insert_at(list, 0, index-1)
        list = List.insert_at(list, 0, index+1)
    end
    list
  end

  def imp2DTopology(index, totalActors, list) do
    rows = :math.sqrt(totalActors) |> round
    random_number = :rand.uniform(totalActors)
    if rem(index, rows) == 0 do
      cond do
        index == rows ->
          list = List.insert_at(list, 0, index-1)
          list = List.insert_at(list, 1, index+rows)
          list = List.insert_at(list, 2, random_number)
        index == totalActors ->
          list = List.insert_at(list, 0, index-1)
          list = List.insert_at(list, 1, index-rows)
          list = List.insert_at(list, 2, random_number)
        index != rows && index != totalActors ->
          list = List.insert_at(list, 0, index-1)
          list = List.insert_at(list, 1, index-rows)
          list = List.insert_at(list, 2, index+rows)
          list = List.insert_at(list, 3, random_number)
      end
    end

    if rem(index, rows) == 1 do
      cond do
        index == 1 ->
          list = List.insert_at(list, 0, index+1)
          list = List.insert_at(list, 1, index+rows)
          list = List.insert_at(list, 2, random_number)
        index == totalActors-rows+1 ->
          list = List.insert_at(list, 0, index+1)
          list = List.insert_at(list, 1, index-rows)
          list = List.insert_at(list, 2, random_number)
        index != 1 && index != totalActors-rows+1 ->
          list = List.insert_at(list, 0, index+1)
          list = List.insert_at(list, 1, index-rows)
          list = List.insert_at(list, 2, index+rows)
          list = List.insert_at(list, 3, random_number)
      end
    end

    if index<rows && index>1 do
      list = List.insert_at(list, 0, index-1)
      list = List.insert_at(list, 1, index+1)
      list = List.insert_at(list, 2, index+rows)
      list = List.insert_at(list, 3, random_number)
    end

    if index<totalActors && index>totalActors-rows+1 do
      list = List.insert_at(list, 0, index-1)
      list = List.insert_at(list, 1, index+1)
      list = List.insert_at(list, 2, index-rows)
      list = List.insert_at(list, 3, random_number)
    end

    if rem(index, rows) != 0 && rem(index, rows) != 1 && index>rows && index<totalActors-rows+1 do
      list = List.insert_at(list, 0, index-1)
      list = List.insert_at(list, 1, index+1)
      list = List.insert_at(list, 2, index-rows)
      list = List.insert_at(list, 3, index+rows)
      list = List.insert_at(list, 4, random_number)
    end
    list
  end

  def startNode(args) do
    {:ok, _} = Supervisora.start_link
    networkFormation(args)
  end

end