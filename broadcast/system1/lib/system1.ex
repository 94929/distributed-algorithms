defmodule System1 do

    def main do
        IO.puts "System started"

        max_broadcasts = 1000
        timeout = 3000

        n = 5
        peers = for _ <- 1..n, do: spawn Peer, :start, []

        for peer <- peers do
            send peer, {:broadcast, max_broadcasts, timeout}
        end

        IO.puts "Broadcasting started"
    end # main

    def main_net do
        IO.puts "System started"
        
        max_broadcasts = 1000
        timeout = 3000

        n = 5
        peers = for i <- 1..n, do: DAC.node_spawn "peer", i, Peer, :start, []
        for peer <- peers do 
            send peer, {:broadcast, max_broadcasts, timeout}
        end

        IO.puts "System started"
    end # main_net
end

