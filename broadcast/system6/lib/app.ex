defmodule App do
  
  def start do
    {rb, pls, id} = receive do {:bind, rb, pls, id} -> {rb, pls, id} end
    messages = for pl <- pls, into: %{}, do: {pl, 0}
    
    receive do
      {:broadcast, max_broadcasts, timeout} ->
        timeout_time = :os.system_time(:millisecond) + timeout
        next(max_broadcasts, max_broadcasts, timeout_time, messages, id, rb, 1, 1)
    end
  end

  defp next(remaining, max_broadcasts, timeout_time, messages, id, rb, rn, sn) do
    if :os.system_time(:millisecond) >= timeout_time do
      finish remaining, max_broadcasts, messages, id
    else
      # interleave probabilistically 
      # based on how many times the process has sent and received
      if :rand.uniform < (sn / (rn + sn)) do
        receive do
          {:rb_deliver, from, _msg} -> 
            newMessages = %{messages | from => messages[from] + 1}
            next(remaining, max_broadcasts, timeout_time, newMessages, id, rb, rn + 1, sn)
        after
          0 -> next(remaining, max_broadcasts, timeout_time, messages, id, rb, rn, sn)
        end
      else
        if remaining > 0 do
          unique_message = {remaining, self()}
          send rb, {:rb_broadcast, unique_message} 
          next(remaining - 1, max_broadcasts, timeout_time, messages, id, rb, rn, sn + 5)
        else
          next(remaining, max_broadcasts, timeout_time, messages, id, rb, rn, sn)
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
