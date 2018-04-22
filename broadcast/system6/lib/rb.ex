defmodule RB do

  def start do
    receive do {:bind, c, beb, self} -> next c, beb, self, MapSet.new end
  end

  defp next c, beb, self, delivered do
    receive do
      {:rb_broadcast, m} ->
        send beb, {:beb_broadcast, {:rb_data, self, m}}
        next c, beb, self, delivered
      {:beb_deliver, from, {:rb_data, sender, m} = rb_m} ->
        if MapSet.member? delivered, m do
          next c, beb, self, delivered
        else
          send c, {:rb_deliver, sender, m}
          send beb, {:beb_broadcast, rb_m}
          next c, beb, self, MapSet.put(delivered, m)
        end
    end
  end

end
