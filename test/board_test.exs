defmodule BoardTest do
  use ExUnit.Case
  alias SocialNetwork.Board

  test "Alice post a message, should be able to get her own messages" do
    start_supervised!({Board, [:alice, "tokenA"]}, id: :alice)

    Board.publish(:alice, "tokenA", "hello world")
    {:ok, messages} = Board.get_messages(:alice)
    assert messages == ["hello world"]
  end

  test "Alice post two messages, should return them in reverse order" do
    start_supervised!({Board, [:alice, "tokenA"]}, id: :alice)

    Board.publish(:alice, "tokenA", "hello world")
    Board.publish(:alice, "tokenA", "hello ale!")

    {:ok, messages} = Board.get_messages(:alice)

    assert messages == ["hello ale!", "hello world"]
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

    assert Board.get_messages(:alice) == {:ok, ["Hello I'm alice"]}
    assert Board.get_messages(:bob) == {:ok, ["Hello I'm bob"]}
  end
end
