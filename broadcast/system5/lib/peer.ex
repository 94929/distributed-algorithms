defmodule Peer do

  def start do
    app = spawn(App, :start, [])
    pl = spawn(LPL, :start, [])
    beb = spawn(BEB, :start, [])
    {parent, r, killPeer} = receive do {:bind, parent, r, killPeer} 
      -> {parent, r, killPeer} end

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

    if i == 3 and killPeer do
      Process.sleep(5)
      Process.exit(app, :kill)
      Process.exit(pl, :kill)
      Process.exit(beb, :kill)
      Process.exit(self(), :kill)
    end
    
  end

end
