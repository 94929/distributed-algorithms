defmodule PL do

  def start do

    receive do
      {:bindBeb, beb} -> next beb, 1, 1
    end 

  end

  # add this pl change to system 2
  def next(beb, sendCount, receiveCount) do
    # interleave probabilistically
    # based on how many times the process has sent and received
    if :rand.uniform < (sendCount / (receiveCount + sendCount)) do
      receive do 
        {:pl_message, src, msg} -> 
          send beb, {:pl_deliver, src, msg}
          next beb, sendCount, receiveCount + 1
      after
        0 -> next beb, sendCount, receiveCount
      end
    else
      receive do
        {:pl_send, dest, msg} -> 
          send dest, {:pl_message, self(), msg}
          next beb, sendCount + 1, receiveCount
      after
        0 -> next beb, sendCount, receiveCount
      end
    end
  end

end
