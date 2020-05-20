defmodule BoardTest do
  use ExUnit.Case
  alias SocialNetwork.Board

  test "Alice post a message, should be able to get her own messages" do
    start_supervised!({Board, [:alice, "tokenA"]}, id: :alice)

    Board.publish(:alice, "tokenA", "hello world")
    {:ok, messages} = Board.get_messages(:alice)
    assert [%SocialNetwork.Message{user: :alice, text: "hello world", timestamp: _}] = messages
  end

  test "Alice post two messages, should return them in reverse order" do
    start_supervised!({Board, [:alice, "tokenA"]}, id: :alice)

    Board.publish(:alice, "tokenA", "hello world")
    Board.publish(:alice, "tokenA", "hello ale!")

    {:ok, messages} = Board.get_messages(:alice)

    assert [
      %SocialNetwork.Message{user: :alice, text: "hello ale!", timestamp: _},
      %SocialNetwork.Message{user: :alice, text: "hello world", timestamp: _}
    ] = messages
  end

  test "Alice post in Bobs timeline, should fail" do
    start_supervised!({Board, [:alice, "tokenA"]}, id: :alice)
    start_supervised!({Board, [:bob, "tokenB"]}, id: :bob)

    Board.publish(:bob, "tokenA", "hello world")

    {:ok, messages} = Board.get_messages(:bob)

    assert messages == []
  end

  test "Alice and Bob publish in their own timeline" do
    start_supervised!({Board, [:alice, "tokenA"]}, id: :alice)
    start_supervised!({Board, [:bob, "tokenB"]}, id: :bob)

    Board.publish(:alice, "tokenA", "Hello I'm alice")
    Board.publish(:bob, "tokenB", "Hello I'm bob")

    assert {:ok, [%SocialNetwork.Message{user: :alice, text: "Hello I'm alice", timestamp: _}]} = Board.get_messages(:alice)
    assert {:ok, [%SocialNetwork.Message{user: :bob, text: "Hello I'm bob", timestamp: _}]} = Board.get_messages(:bob)
  end

  test "Charlie can subscribe to Alice's and Bob's timelines, and view an aggregated list of all subscriptions" do
    start_supervised!({Board, [:alice, "tokenA"]}, id: :alice)
    start_supervised!({Board, [:bob, "tokenB"]}, id: :bob)
    start_supervised!({Board, [:charlie, "tokenC"]}, id: :charlie)

    Board.subscribe(:charlie, "tokenC", :alice)
    Board.subscribe(:charlie, "tokenC", :bob)

    Board.publish(:alice, "tokenA", "Hello I'm alice")
    Board.publish(:bob, "tokenB", "Hello I'm bob")

    {:ok, msg} = Board.get_messages(:charlie)

    assert [
      %SocialNetwork.Message{user: :bob, text: "Hello I'm bob", timestamp: _},
      %SocialNetwork.Message{user: :alice, text: "Hello I'm alice", timestamp: _}] = msg
  end

  end
