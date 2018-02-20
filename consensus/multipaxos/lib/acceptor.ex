defmodule Acceptor do
    
    def start do
        ballot_num = 0
        accepted = MapSet.new
        next ballot_num, accepted
    end

    def next ballot_num, accepted do
        
        receive do
            {:p1a, scout, b} ->
                if b > ballot_num do
                    ballot_num = b
                end
                send scout, {:p1b, self(), ballot_num, accepted}
            {:p2a, commander, {b, s, c}} ->
                if ballot_num == b do
                    accepted = MapSet.put accepted, {b, s, c}
                end
                send commander, {:p2b, self(), ballot_num}
        end
        next ballot_num, accepted
    end
end

