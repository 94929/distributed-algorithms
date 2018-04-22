defmodule Peer do

  def start do

    app = spawn(App, :start, [])
    pl = spawn(PL, :start, [])
    parent = receive do {:bind, parent} -> parent end

    send parent, {:bind, pl}
    send pl, {:bindApp, app}

    pls = receive do {:bindPls, pls} -> pls end
    i = Enum.find_index(pls, fn(x) -> x == pl end)
    send app, {:bind, pl, pls, i}

    IO.puts "Peer #{i} started"
    
    receive do 
      {:broadcast, total_broadcasts, timeout} ->
        send app, {:broadcast, total_broadcasts, timeout}
    end
    
  end

end
