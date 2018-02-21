defmodule Replica do

    def start leaders, database, monitor do
        slot_in = 1
        slot_out = 1
        requests = MapSet.new
        proposals = Map.new
        decisions = Map.new

        next leaders, database, monitor, slot_in, slot_out, requests, proposals, decisions
    end #_start

    def next leaders, database, monitor, slot_in, slot_out, requests, proposals, decisions do
        receive do
        {:request, c} ->
            requests = MapSet.put requests, c
        {:decision, s, c} ->
            decisions = Map.put decisions, s, c
            {proposals, requests, slot_out} = apply_decisions decisions, proposals, requests, slot_out, database, monitor
        end #_receive
        # TODO:: remember to UPDATE STATE
        propose leaders, slot_in, slot_out, requests, proposals, decisions
        next leaders, database, monitor, slot_in, slot_out, requests, proposals, decisions
    end #_next

    def apply_decisions decisions, proposals, requests, slot_out, database, monitor do
        case decisions[slot_out] do
        nil -> 
            {proposals, requests, slot_out}
        d_command ->
            p_command = proposals[slot_out] 
            if p_command != nil do
                proposals = Map.delete proposals, slot_out
                if d_command != p_command do
                    requests = MapSet.put requests, p_command
                end #_if
            end #_if
            perform d_command, decisions, slot_out, database, monitor
            apply_decisions decisions, proposals, requests, slot_out, database, monitor
        end #_case
    end #_apply_decisions

    def perform d_command, decisions, slot_out, database, monitor do
        # d_command

    end #_perform

    def propose leaders, slot_in, slot_out, requests, proposals, decisions do

    end #_propose
    
end #_Replica

