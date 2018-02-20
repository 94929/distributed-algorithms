defmodule Scout do

    def start leader, acceptors, b do
        wait_for = acceptors
        pvalues = MapSet.new
        
        for acceptor <- acceptors do
            send acceptor, {:p1a, self(), b}
        end # _for

        next leader, acceptors, wait_for, pvalues, b
    end #_start

    def next leader, acceptors, wait_for, pvalues, b do
        receive do
            {:p1b, acceptor, ballot_num, pvalue} ->
                if ballot_num == b do
                    pvalues = MapSet.put pvalues, pvalue              
                    wait_for = List.delete wait_for, acceptor
                    if (length wait_for) < (length acceptors) / 2 do
                        send leader, {:adopted, b, pvalues}
                        Process.exit(self(), :normal)
                    end #_if
                else
                    send leader, {:preempted, ballot_num}
                    Process.exit(self(), :normal)
                end #_if
                
        end #_receive
        next leader, acceptors, wait_for, pvalues, b
    end #_next
end #_Scout

