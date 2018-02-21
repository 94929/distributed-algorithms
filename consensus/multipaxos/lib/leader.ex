defmodule Leader do

    def start config do
        {replicas, acceptors} = receive do
            {:bind, acceptors, replicas} ->
                {replicas, acceptors}
            end #_receive
        ballot_num = {0, self()}
        active = false
        proposals = Map.new
        spawn Scout, :start, [self(), acceptors, ballot_num]

        next acceptors, replicas, ballot_num, active, proposals
    end #_start

    def next acceptors, replicas, ballot_num, active, proposals do

        receive do 
        {:propose, s, c} ->
            # there is no command in proposals that has s 
            if Map.has_key? proposals, s do
                proposals = Map.put proposals, s, c
                if active do
                    spawn Commander, :start, [self(), acceptors, replicas, {ballot_num, s, c}]
                end #_if
            end #_if
        {:adopted, ballot_num, pvals} ->
            # turn pvals into a list
            proposals = update_proposals Map.new, MapSet.to_list(pvals), proposals
            for {s, c} <- proposals do
                spawn Commander, :start, [self(), acceptors, replicas, {ballot_num, s, c}]
            end #_for
            active = true
        {:preempted, {r, lambda}} ->
            if {r, lambda} > ballot_num do
                active = false
                ballot_num = {r+1, self()}
                spawn Scout, :start, [self(), acceptors, ballot_num]
            end #_if
        end #_receive
        next acceptors, replicas, ballot_num, active, proposals
    end #_next

    def update_proposals max, pvals, proposals do
        IO.puts "hello"  
        case pvals do
        [] -> 
            proposals
        [pval | pvals] ->
            bn = max[elem(pval, 1)]
            if bn == nil or bn < elem(pval, 0) do
                max = Map.put max, elem(pval, 1), elem(pval, 0)
                proposals = Map.put proposals, elem(pval, 1), elem(pval, 2)
            end #_if
            update_proposals max, pvals, proposals
        end #_case
    end #_update_pvals

end #_Leader

