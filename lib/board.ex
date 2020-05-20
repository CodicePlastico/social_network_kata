
defmodule SocialNetwork.Message do
  defstruct [:user, :text, :timestamp]
end


defmodule SocialNetwork.Board do
  use GenServer

  defstruct [:user, :token, :messages, :subscriptions]

  def start_link([user, token]) do
    GenServer.start_link(__MODULE__, [user, token], name: user)
  end

  def init([user, token]) do
    {:ok, %{user: user, token: token, messages: [], subscriptions: []}}
  end

  def publish(user, token, message) do
    GenServer.cast(user, {:publish, token, message})
  end

  def get_messages(user) do
    GenServer.call(user, :get_messages)
  end

  def subscribe(user, _token, dest) do
    GenServer.cast(user, {:subscribe, dest})
  end

  def handle_cast({:publish, current_token, message}, %{user: user, token: token, messages: messages} = state) do
    if(current_token == token) do
      msg = %SocialNetwork.Message{user: user, text: message, timestamp: DateTime.utc_now()}

      {:noreply, %{state | messages: [msg] ++ messages}}
    else
      {:noreply, state}
    end
  end

  def handle_cast({:subscribe, subscription}, %{subscriptions: subscriptions} = state) do
    {:noreply, %{state | subscriptions: subscriptions ++ [subscription]}}
  end

  def handle_call(:get_messages, _from, %{messages: messages, subscriptions: subscriptions} = state) do

    other_messages = Enum.flat_map(subscriptions, fn s ->
      {:ok, msg} = SocialNetwork.Board.get_messages(s)
      msg
    end)

    sorted_message = Enum.sort(other_messages, fn a, b -> a.timestamp > b.timestamp end)

    {:reply, {:ok, messages ++ sorted_message}, state}
  end
end
