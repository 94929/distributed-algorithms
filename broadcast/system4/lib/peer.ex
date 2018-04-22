defmodule Peer do

  def start do

    app = spawn(App, :start, [])
    pl = spawn(LPL, :start, [])
    beb = spawn(BEB, :start, [])
    {parent, r} = receive do {:bind, parent, r} -> {parent, r} end

    send parent, {:bind, pl}
    send pl, {:bind, beb, r}

    pls = receive do {:bindPls, pls} -> pls end
    send beb, {:bind, pl, app, pls}

    i = Enum.find_index(pls, fn(x) -> x == pl end)
    send app, {:bind, beb, pls, i}

    IO.puts "Peer #{i} ready"
    
    receive do 
      {:broadcast, total_broadcasts, timeout} ->
        send app, {:broadcast, total_broadcasts, timeout}
    end
    
  end

end
