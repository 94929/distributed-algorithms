defmodule BEB do

  def start do
    receive do {:bind, pl, app, processes} -> next processes, pl, app, 1, 1 end
  end

  def next processes, pl, app, sendCount, receiveCount do
    # interleave probabilistically
    # based on how many times the process has sent and received
    if :rand.uniform < (sendCount / (receiveCount + sendCount)) do
      receive do
        {:pl_deliver, from, msg} ->
          #IO.puts "receive"
          send app, {:beb_deliver, from, msg}
          next processes, pl, app, sendCount, receiveCount + 1
      after
        0 -> next processes, pl, app, sendCount, receiveCount 
      end
    else
      receive do
        {:beb_broadcast, msg} ->
          #IO.puts "send"
          for dest <- processes, do:
            send pl, {:pl_send, dest, msg}
          next processes, pl, app, sendCount + 5, receiveCount
      after
        0 -> next processes, pl, app, sendCount, receiveCount 
      end
    end
  end

end
