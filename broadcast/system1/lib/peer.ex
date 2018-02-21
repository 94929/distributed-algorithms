defmodule Peer do

    def start do
        {peers, id} = 
            receive do
            {:bind, peers, id} ->
                {peers, id}
            end # receive

        IO.puts "Peer #{id} started"

        msgs = for peer <- peers, into: %{}, do: {peer, 0}

        receive do
        {:broadcast, max_broadcasts, timeout} ->
            timeout = :os.system_time :millisecond + timeout
            next max_broadcasts, max_broadcasts, timeout, msgs, id
        end # receive
    end # start

    defp next remains, do

    end # next

    defp halt rems, max_bcs, msgs, id do

    end # halt
end # Peer

