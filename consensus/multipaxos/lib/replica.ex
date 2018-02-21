defmodule Replica do

    def start config, database, monitor do
        leaders = receive do
            {:bind, leaders} ->
                leaders
            end
        slot_in = 1
        slot_out = 1
        requests = MapSet.new
        proposals = Map.new
        decisions = Map.new

        next leaders, database, monitor, slot_in, slot_out, requests, proposals, decisions, config
    end #_start

    def next leaders, database, monitor, slot_in, slot_out, requests, proposals, decisions, config do
        receive do
        {:request, c} ->
            requests = MapSet.put requests, c
        {:decision, s, c} ->
            decisions = Map.put decisions, s, c
            {proposals, requests, slot_out} = apply_decisions decisions, proposals, requests, slot_out, database, monitor
        end #_receive
        # TODO:: remember to UPDATE STATE
        {slot_in, requests, proposals} = propose leaders, slot_in, slot_out, MapSet.to_list(requests), proposals, decisions, config
        requests = MapSet.new requests
        next leaders, database, monitor, slot_in, slot_out, requests, proposals, decisions, config
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
            slot_out = perform d_command, decisions, slot_out, database, monitor
            apply_decisions decisions, proposals, requests, slot_out, database, monitor
        end #_case
    end #_apply_decisions

    def perform_helper n, slot_out, decisions, d_command do
        c = decisions[n]
        cond do
        n >= slot_out ->
            false
        c == d_command ->
            true
        true ->
            perform_helper n+1, slot_out, decisions, d_command
        end
    end

    def perform d_command, decisions, slot_out, database, monitor do
        slot_found = perform_helper 1, slot_out, decisions, d_command
        if not slot_found do
            {client, cid, op} = d_command
            send database, {:execute, op}
            send client, {:response, cid, true}
        end #_if
        slot_out + 1
    end #_perform

    def propose leaders, slot_in, slot_out, requests, proposals, decisions, config do
        cond do
        slot_in < slot_out + config.window and requests != [] ->
            c = decisions[slot_in]
            if c == nil do
                [request | requests] = requests
                proposals = Map.put proposals, slot_in, request
                for leader <- leaders, do: send leader, {:propose, slot_in, request}
            end #_if
            slot_in = slot_in + 1
            propose leaders, slot_in, slot_out, requests, proposals, decisions, config
        true ->
            {slot_in, requests, proposals}
        end #_cond
    end #_propose
    
end #_Replica

