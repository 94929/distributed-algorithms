defmodule App do
  
  def start do

    {appPl, pls, id} = receive do {:bind, appPl, pls, id} -> {appPl, pls, id} end
    messages = for pl <- pls, into: %{}, do: {pl, 0}

    receive do
      {:broadcast, max_broadcasts, timeout} ->
        timeout_time = :os.system_time(:millisecond) + timeout
        next(max_broadcasts, max_broadcasts, timeout_time, messages, id, appPl)
    end
  end

  defp next(remaining, max_broadcasts, timeout_time, messages, id, appPl) do
    
    if :os.system_time(:millisecond) >= timeout_time do
      finish remaining, max_broadcasts, messages, id
    else
      receive do
        {:pl_deliver, pl, _msg} -> 
          newMessages = %{messages | pl => messages[pl] + 1}
          next(remaining, max_broadcasts, timeout_time, newMessages, id, appPl)
      after
        0 -> 
          if remaining > 0 do
            for {pl, _} <- messages, do: send appPl, {:pl_send, pl, " "}
            next(remaining - 1, max_broadcasts, timeout_time, messages, id, appPl)
          else
            next(remaining, max_broadcasts, timeout_time, messages, id, appPl)
          end
      end
    end
  end
  
  defp finish(remaining, max_broadcasts, messages, id) do
    strings = for {_pl, count} <- messages, do: "{#{max_broadcasts - remaining}, #{count}}"
    
    output = Enum.join(strings, " ")
    IO.puts "#{id}: #{output}"
  end

end
