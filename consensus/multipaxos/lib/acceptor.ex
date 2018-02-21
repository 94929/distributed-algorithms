
# Jaspreet Randhawa (jsr15) and Jinsung Ha (jsh114) 

defmodule Acceptor do
    
    def start config do
        ballot_num = 0
        accepted = MapSet.new
        next ballot_num, accepted
    end # start

    def next ballot_num, accepted do
        
        receive do
        {:p1a, scout, b} ->
            #IO.puts "p1a received"
            ballot_num =
                cond do
                    b > ballot_num -> b
                    true -> ballot_num
                end
            send scout, {:p1b, self(), ballot_num, accepted}
            next ballot_num, accepted
        {:p2a, commander, {b, s, c}} ->
            #IO.puts "p2a received"
            accepted = 
                cond do
                    ballot_num == b -> MapSet.put accepted, {b, s, c}
                    true -> accepted
                end
            send commander, {:p2b, self(), ballot_num}
            next ballot_num, accepted
        end #_receive
    end # next
end # Acceptor

