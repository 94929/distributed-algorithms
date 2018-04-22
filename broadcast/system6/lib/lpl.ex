defmodule LPL do

  def start do

    receive do
      {:bind, beb, reliability} -> next beb, 1, 1, reliability
    end 

  end

  # add this pl change to system 2
  def next(beb, sendCount, receiveCount, reliability) do
    randomNum = :rand.uniform
    sendReceiveRatio = sendCount / (receiveCount + sendCount) 

    # interleave probabilistically 
    # based on how many times the process has sent and received
    if randomNum < sendReceiveRatio do
      receive do 
        {:pl_message, src, msg} -> 
          #IO.puts "pl message"
          send beb, {:pl_deliver, src, msg}
          next beb, sendCount, receiveCount + 1, reliability
      after
        0 -> next beb, sendCount, receiveCount, reliability
      end
    else
      receive do
        {:pl_send, dest, msg} -> 
          #IO.puts "pl send"
          if :rand.uniform < reliability do
            send dest, {:pl_message, self(), msg}
          end
          next beb, sendCount + 1, receiveCount, reliability
      after
        0 -> next beb, sendCount, receiveCount, reliability
      end
    end
  end

end
