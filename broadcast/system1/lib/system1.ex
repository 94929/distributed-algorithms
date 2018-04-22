defmodule System1 do
  
  def main do
    IO.puts "System started"

    max_broadcasts = 1000
    timeout = 3000
    
    n = 5
    peers = for _ <- 0..n-1, do: spawn(Peer, :start, [])
    sortedPeers = Enum.sort(peers)
    
    for i <- 0..n-1, do: send Enum.at(sortedPeers, i), {:bind, sortedPeers, i}

    IO.puts "Broadcasting started"
    for peer <- sortedPeers, do: send peer, {:broadcast, max_broadcasts, timeout}

  end
  
  def main_net do
    IO.puts "System started"
    Process.sleep(5000)

    max_broadcasts = 1000
    timeout = 3000
    
    n = 5
    peers = for i <- 0..n-1, do: DAC.node_spawn("peer", i, Peer, :start, [])
    sortedPeers = Enum.sort(peers)

    for i <- 0..n-1, do: send Enum.at(sortedPeers, i), {:bind, sortedPeers, i}

    Process.sleep(5000)
    IO.puts "Broadcasting started"
    for peer <- sortedPeers, do: send peer, {:broadcast, max_broadcasts, timeout}

  end

end
