
# Jaspreet Randhawa (jsr15) and Jinsung Ha (jsh114) 

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
    end # start

    def next acceptors, replicas, ballot_num, active, proposals do

        receive do 
        {:propose, s, c} ->
            #IO.puts "propose received"
            proposals =
                if not Map.has_key? proposals, s do
                    if active do
                        spawn Commander, :start, [self(), acceptors, replicas, {ballot_num, s, c}]
                    end #_if
                    Map.put proposals, s, c
                else
                    proposals
                end #_if
            next acceptors, replicas, ballot_num, active, proposals
        {:adopted, ballot_num, pvals} ->
            #IO.puts "adopted received"
            proposals = update_proposals Map.new, MapSet.to_list(pvals), proposals
            for {s, c} <- proposals do
                spawn Commander, :start, [self(), acceptors, replicas, {ballot_num, s, c}]
            end #_for
            active = true
            next acceptors, replicas, ballot_num, active, proposals
        {:preempted, {r, lambda}} ->
            # IO.puts "preempted received"
            {active, ballot_num} = 
                if {r, lambda} > ballot_num do
                    spawn Scout, :start, [self(), acceptors, ballot_num]
                    {false, {r+1, self()}}
                else
                    {active, ballot_num}
                end #_if
            next acceptors, replicas, ballot_num, active, proposals
        end #_receive
    end # next

    def update_proposals max, pvals, proposals do
        case pvals do
        [] -> 
            proposals
        [pval | pvals] ->
            bn = max[elem(pval, 1)]
            {max, proposals} = 
                if bn == nil or bn < elem(pval, 0) do
                    max = Map.put max, elem(pval, 1), elem(pval, 0)
                    proposals = Map.put proposals, elem(pval, 1), elem(pval, 2)
                    {max, proposals}
                else
                    {max, proposals}
                end #_if
            update_proposals max, pvals, proposals
        end #_case
    end # update_pvals

end # Leader

