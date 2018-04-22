defmodule BEB do

  def start do
    receive do {:bind, pl, rb, processes} -> next processes, pl, rb, 1, 1 end
  end

  def next processes, pl, rb, sendCount, receiveCount do
    # interleave probabilistically 
    # based on how many times the process has sent and received
    if :rand.uniform < (sendCount / (receiveCount + sendCount)) do
      receive do
        {:pl_deliver, from, msg} ->
          send rb, {:beb_deliver, from, msg}
          next processes, pl, rb, sendCount, receiveCount + 1
      after
        0 -> next processes, pl, rb, sendCount, receiveCount 
      end
    else
      receive do
        {:beb_broadcast, msg} ->
          for dest <- processes, do:
            send pl, {:pl_send, dest, msg}
          next processes, pl, rb, sendCount + 5, receiveCount
      after
        0 -> next processes, pl, rb, sendCount, receiveCount 
      end
    end
  end

end
