defmodule MapperTest do

  use ExUnit.Case, async: true

  test "map to keyword_list string value" do
    res = %{a: "a", b: "b"} |> Mapper.map_to_list
    assert [a: "a", b: "b"] |> Enum.sort == res |> Enum.sort
  end

  test "map to keyword_list number value" do
    res = %{a: "a", b: 123} |> Mapper.map_to_list
    assert [a: "a", b: 123] |> Enum.sort == res |> Enum.sort
  end

  test "map to keyword_list 1 level" do
    res = %{a: "a", b: %{c: "c"}} |> Mapper.map_to_list
    assert [a: "a", b: [c: "c"]] |> Enum.sort == res |> Enum.sort
  end

  test "map to keyword_list 2 levels" do
    res = %{a: "a", b: %{c: %{d: "d"}}} |> Mapper.map_to_list
    assert [a: "a", b: [c: [d: "d"]]] |> Enum.sort == res |> Enum.sort
  end

  test "map to keyword_list 3 levels" do
    res = %{a: %{a1: "a1"}, b: %{c: %{d: %{e: "e"}}}} |> Mapper.map_to_list
    assert [a: [a1: "a1"], b: [c: [d: [e: "e"]]]] |> Enum.sort == res |> Enum.sort
  end

  test "map to keyword_list with list" do
    res = %{a: %{a1: "a1"}, b: %{c: %{d: %{e: ["TEST"]}}}} |> Mapper.map_to_list
    assert [a: [a1: "a1"], b: [c: [d: [e: ["TEST"]]]]] |> Enum.sort == res |> Enum.sort
  end

  test "map to keyword_list with empty list" do
    res = %{a: %{a1: "a1"}, b: %{c: %{d: %{e: []}}}} |> Mapper.map_to_list
    assert [a: [a1: "a1"], b: [c: [d: [e: []]]]] |> Enum.sort == res |> Enum.sort
  end

end
