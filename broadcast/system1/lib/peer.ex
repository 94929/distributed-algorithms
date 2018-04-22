defmodule Peer do
  
  def start do

    {peers, id} = receive do {:bind, peers, id} -> {peers, id} end

    IO.puts "Peer #{id} started"

    messages = for peer <- peers, into: %{}, do: {peer, 0}
    
    receive do
      {:broadcast, max_broadcasts, timeout} ->
        timeout_time = :os.system_time(:millisecond) + timeout
        next(max_broadcasts, max_broadcasts, timeout_time, messages, id)
    end
  end

  defp next(remaining, max_broadcasts, timeout_time, messages, id) do
    if :os.system_time(:millisecond) >= timeout_time do
      finish remaining, max_broadcasts, messages, id
    else
      receive do
        {:message, peer, _msg} -> 
          newMessages = %{messages | peer => messages[peer] + 1}
          next(remaining, max_broadcasts, timeout_time, newMessages, id)
      after
        0 -> 
          if remaining > 0 do
            for {peer, _} <- messages, do: send peer, {:message, self(),  " "}
            next(remaining - 1, max_broadcasts, timeout_time, messages, id)
          else
            next(remaining, max_broadcasts, timeout_time, messages, id)
          end
      end
    end
  end
  
  defp finish(remaining, max_broadcasts, messages, id) do
    strings = for {_peer, count} <- messages, do: "{#{max_broadcasts - remaining}, #{count}}"
    
    output = Enum.join(strings, " ")
    IO.puts "#{id}: #{output}"
  end

end
