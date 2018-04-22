defmodule System5 do
  
  def main do
    IO.puts "System started"

    reliability = 0.5 
    max_broadcasts = 1000
    timeout = 3000
    killPeer = true
    
    n = 5
    peers = for _ <- 0..n-1, do: spawn(Peer, :start, []);
   
    for peer <- peers, do: send peer, {:bind, self(), reliability, killPeer}

    plComponents = for _ <- 0..n-1, do: receivePl()
    sortedPls = Enum.sort(plComponents)
    
    for peer <- peers, do: send peer, {:bindPls, sortedPls}

    Process.sleep(5000)

    IO.puts "Begin broadcasting"
    for peer <- peers, do: send peer, {:broadcast, max_broadcasts, timeout}

  end
  
  def main_net do
    IO.puts "System started"
    Process.sleep(5000)

    reliability = 0.5 
    max_broadcasts = 1000
    timeout = 3000
    killPeer = true
    
    n = 5
    peers = for i <- 0..n-1, do: DAC.node_spawn("peer", i, Peer, :start, [])
    
    for peer <- peers, do: send peer, {:bind, self(), reliability, killPeer}

    plComponents = for _ <- 0..n-1, do: receivePl()
    sortedPls = Enum.sort(plComponents)
    
    for peer <- peers, do: send peer, {:bindPls, sortedPls}

    Process.sleep(5000)

    IO.puts "Begin broadcasting"
    for peer <- peers, do: send peer, {:broadcast, max_broadcasts, timeout}
  end

  defp receivePl() do
   receive do {:bind, pl} -> pl end 
  end

end
