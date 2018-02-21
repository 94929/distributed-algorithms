
# Jaspreet Randhawa (jsr15) and Jinsung Ha (jsh114) 

defmodule Commander do

    def start leader, acceptors, replicas, {b, s, c} do
        #IO.puts "cmd spawned"

        wait_for = acceptors
        for acceptor <- acceptors do
            send acceptor, {:p2a, self(), {b, s, c}}
        end #_for
        next leader, acceptors, replicas, wait_for, {b, s, c}
    end # start

    def next leader, acceptors, replicas, wait_for, {b, s, c} do
        #IO.puts "cmd next called"

        receive do
        {:p2b, acceptor, ballot_num} ->
            #IO.puts "p2b"

            if ballot_num == b do
                wait_for = List.delete wait_for, acceptor
                if (length wait_for) < (length acceptors) / 2 do
                    for replica <- replicas do
                        send replica, {:decision, s, c}
                    end #_for
                    Process.exit self(), :normal
                end #_if
                next leader, acceptors, replicas, wait_for, {b, s, c}
            else
                send leader, {:preempted, ballot_num}
                Process.exit self(), :normal
            end #_if
        end #_receive
    end # next
end # Commander

