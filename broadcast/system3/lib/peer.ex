defmodule Peer do

  def start do

    app = spawn(App, :start, [])
    pl = spawn(PL, :start, [])
    beb = spawn(BEB, :start, [])
    parent = receive do {:bind, parent} -> parent end

    send parent, {:bind, pl}
    send pl, {:bindBeb, beb}

    pls = receive do {:bindPls, pls} -> pls end
    send beb, {:bind, pl, app, pls}

    i = Enum.find_index(pls, fn(x) -> x == pl end)
    send app, {:bind, beb, pls, i}

    IO.puts "Peer #{i} started"
    
    receive do 
      {:broadcast, total_broadcasts, timeout} ->
        send app, {:broadcast, total_broadcasts, timeout}
    end
    
  end

end
