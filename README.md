# Gossip-protocol
Gossip type algorithms can be used both for group communication and for aggregate computation. The goal of this project is to determine the convergence of such algorithms through a simulator based on actors written in Elixir. Since actors in Elixir are fully asynchronous, the particular type of Gossip implemented is the so called Asynchronous Gossip.
# Working
In this project, I implemented 4 different types of topologies using tuples-

1. Full Network : Every actor is a neigbour to every other actor

2. 2D Grid : All the actors form a part of a 2 dimensional matrix

3. Line : All the actors are placed in a line with each actor have 2 neighbours

4. Imperfect 2D Grid : All the actors form a part of a 2 dimensional matrix and one other random node is also added as a neighbour.

Each topology is used as a part of 2 different algorithms. Gossip and push-sum.

# Gossip

In gossip, N number of actors are created and each actor passes messages to its neighbours depending on the topology. These actors periodically transmit messages to their neighbours as well. When an actor receives a message, It increments its counter and when a particular actor has seen a message 10 times, it stop transmitting messages. Convergence is reached when 80% of the nodes in the network have stopped transmitting i.e received the message 10 times.

# Push-Sum

In Push-sum, N number of actors are created and each actor has an S value and a W value. The S value is initially set to the corresponding index or actor number of the actor. The W value is initialized to 1. At each round, one actor passes half of its S and W values to a neighbour depending on the topology. The actor that receives these values, adds them to its own S and W values before transmitting it again to it's neighbour. If a particular actor's S/W ratio does not change more than 10^-10 over 3 consecutive rounds, then the actor is said to terminate and the ratio has reached convergence. Terminated actors do not send their S,W values and insted pass whatever value they receive onwards to other neighbours that have not yet terminated. In our network, convergence is reached when 80% of the nodes in the network have reached convergence.

# Largest Networks Built
    # Gossip Algorithm
      Full Network : 50,000 
      2D Grid : 200,000 
      Line : 10,000 
      Imperfect 2D Grid : 200,000

    # Push-Sum Algorithm 
      Full Network : 10,000 
      2D Grid : 1,000 
      Line : 100 
      Imperfect 2D Grid : 10,000
      

