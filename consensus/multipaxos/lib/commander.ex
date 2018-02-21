defmodule Commander do

    def start leader, acceptors, replicas, {b, s, c} do
        wait_for = acceptors
        next leader, acceptors, replicas, wait_for, {b, s, c}
    end #_start

    def next leader, acceptors, replicas, wait_for, {b, s, c} do
        receive do
        {:p2b, acceptor, ballot_num} ->
            if ballot_num == b do
                wait_for = List.delete wait_for, acceptor
                if (length wait_for) < (length acceptors) / 2 do
                    for replica <- replicas do
                        send replica, {:decision, s, c}
                    end #_for
                    Process.exit(self(), :normal)
                end #_if
            else
                send leader, {:preempted, ballot_num}
                Process.exit(self(), :normal)
            end #_if
        end #_receive
        next leader, acceptors, replicas, wait_for, {b, s, c}
    end #_next
end #_Commander

