defmodule SocialNetwork.Board do
  use GenServer

  def start_link([user, token]) do
    GenServer.start_link(__MODULE__, [token], name: user)
  end

  def init([token]) do
    {:ok, {token, []}}
  end

  def publish(user, token, message) do
    GenServer.cast(user, {:publish, token, message})
  end

  def get_messages(user) do
    GenServer.call(user, :get_messages)
  end

  def handle_cast({:publish, current_token, message}, {token, messages}) do
    if(current_token == token) do
      {:noreply, {token, [message] ++ messages}}
    else
      {:noreply, {token, messages}}
    end
  end

  def handle_call(:get_messages, _from, {_, messages} = state) do
    {:reply, {:ok, messages}, state}
  end

end
