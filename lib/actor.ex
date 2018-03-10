defmodule Actora do
    use GenServer

    def start_link(arg \\[]) do
        name = Enum.at(arg,0)
        list = Enum.at(arg,1)
        counter = Enum.at(arg,2)
        sum = Enum.at(arg,3)
        weight = Enum.at(arg,4)
        GenServer.start_link(__MODULE__, [name, list, counter, sum, weight], name: name)
    end

    def handle_cast({:node, actor_name}, state) do
        counter = Enum.at(state, 2) + 1
        name = Enum.at(state, 0)
        list = Enum.at(state, 1)
        #IO.puts "vivek"
        #IO.puts name
        GenServer.cast(name, {:node1, :actor_name})
        {:noreply, [name, list, counter]}    
    end

    def handle_cast({:node1, actor_name}, state) do
        counter = Enum.at(state, 2)
        list = Enum.at(state, 1)
        name = Enum.at(state, 0)
        #IO.inspect list
        if counter <= 10 do
            index = :rand.uniform(length(list))-1
            random_neighbour_index = Enum.at(list,index)
            neighbour_name = :"actor#{random_neighbour_index}"
            #IO.puts neighbour_name

            if counter = 10 do
                IO.puts "entered"
                final_2 = :global.whereis_name(:final_2) #finds pid for receiver process

                send final_2, {:ok,"hello"}             #sends message to receiver once counter is 10
            end
            GenServer.cast(neighbour_name, {:node, neighbour_name})
        end
        GenServer.cast(name, {:node1, :actor_name})
        {:noreply, state}
    end

    def handle_cast({:node2, actor_name, s_rec, w_rec}, state) do
        counter = Enum.at(state, 2)
        name = Enum.at(state, 0)
        list = Enum.at(state, 1)
        s = Enum.at(state, 3)
        w = Enum.at(state, 4)
    #    if counter == 3 do                       #acts as intermediate actor
    #        s_new = s_rec                           #passes s received value to neighbour
    #        w_new = w_rec                           #passes w recieved value to neighbour
    #        index = :rand.uniform(length(list))-1
    #        random_neighbour_index = Enum.at(list,index)
    #        neighbour_name = :"actor#{random_neighbour_index}"
    #        IO.puts actor_name
    #        IO.puts s_new/w_new

    #        GenServer.cast(neighbour_name, {:node2, neighbour_name, s_new, w_new})

    #        IO.puts :os.system_time(:millisecond)
    #        {:noreply, [name, list, counter, s_new, w_new]}
    #    end
        
        if counter < 3 do           #to check if actor alive
            s_old = s               #previous value of s for this actor
            w_old = w               #previous value of w for this actor
            s_new = s + s_rec           #adds received value of s
            w_new = w + w_rec           #adds received value of w
            p = s_new/w_new
            q = s_old/w_old
            r = 10.0e-10
            if p - q < r do        #checks for termination condition
                counter = counter + 1               # for 3 consecutive rounds
            else
                counter = 0
            end
            if counter == 3 do                       # if termination condition satisfied
               # final_2 = :global.whereis_name(:final_2) #finds pid for receiver process
               # send final_2, {:ok,"hello"}             #sends message to receiver once counter is 10
               IO.puts actor_name
               IO.puts s_new/w_new
               final = :global.whereis_name(:final)    #finds main process pid
               send final, {:stop}                     #sends message to main process when numb = 0
            
            end

            #IO.puts name
            s = s_new/2                     #sends half of the s value
            w = w_new/2                     #sends half of the w value
            index = :rand.uniform(length(list))-1
            random_neighbour_index = Enum.at(list,index)
            neighbour_name = :"actor#{random_neighbour_index}"
            #IO.puts s
            #IO.puts w
            GenServer.cast(neighbour_name, {:node2, neighbour_name, s, w})
            {:noreply, [name, list, counter, s, w]}
        end
    end
end