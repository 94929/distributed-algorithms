defmodule PL do

  def start do

    receive do
      {:bindApp, app} -> next app
    end 

  end

  def next(app) do
    receive do 
      {:pl_send, pl, _msg} -> 
        send pl, {:pl_message, self(), " "}
        next app
      {:pl_message, pl, _msg} ->
        send app, {:pl_deliver, pl, " "}
        next app
    end
  end

end
