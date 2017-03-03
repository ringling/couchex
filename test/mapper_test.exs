defmodule MapperTest do

  use ExUnit.Case, async: true

  test "map empty list to list" do
    assert [] == Mapper.list_to_map([])
  end

  test "map tuple list to Map" do
    assert %{"_id" => "id", "_rev" => "rev", "foo" => "bar"} == Mapper.list_to_map([{"_id", "id"}, {"_rev", "rev"}, {"foo", "bar"}])
  end

  test "map tuple list with 2 tuples" do
    assert %{"foo" => "bar", "baz"=>"bozz" } == Mapper.list_to_map([{"foo", "bar"}, {"baz", "bozz"}])
  end

  test "map tuple list to Map 1 level" do
    assert %{"foo" => %{"bar" => "baz"} } == Mapper.list_to_map([{"foo", {"bar", "baz"} }])
  end

  test "map tuple list to Map 2 level" do
    assert %{"foo" => %{"bar" => %{"baz" => "bozz" } } } == Mapper.list_to_map([{"foo", {"bar", {"baz","bozz"} } }])
  end

  test "map tuple list to Map 2 level with tuple list" do
    assert %{"foo" => %{"bar" => [%{"baz" => "bozz" }] } } == Mapper.list_to_map([{"foo", {"bar", [{"baz", "bozz"}] } }])
  end

  test "map tuple list to Map 2 level with list" do
    assert %{"foo" => %{"bar" => %{"baz" => [1,2,3] } } } == Mapper.list_to_map([{"foo", {"bar", {"baz",[1,2,3]} } }])
  end

  test "map tuple list to Map 2 level with empty list" do
    assert %{"foo" => %{"bar" => %{"baz" => [] } } } == Mapper.list_to_map([{"foo", {"bar", {"baz",[]} } }])
  end

  test "map tuple list to Map 2x2" do
    assert %{"a" => %{"b" => %{"c" => "c1" }}, "foo" => %{"bar" => %{"baz" => "bozz" }}} == Mapper.list_to_map([{"a", {"b",{"c","c1"} } },{"foo", {"bar", {"baz","bozz"} } }])
  end

  test "map nested tuple list" do
    resp = [
      {
        [
          {"id", "doc_id_1"},
          {"key", "doc_id_1"},
          {"value", {[{"rev", "1-59414e77c768bc202142ac82c2f129de"}]}},
          {"doc", {[{"_id", "doc_id_1"}, {"_rev", "1-59414e77c768bc202142ac82c2f129de"}, {"key", "value"}]}}
        ]
      },
      {
        [
          {"id", "doc_id_2"},
          {"key", "doc_id_2"},
          {"value", {[{"rev", "1-59414e77c768bc202142ac82c2f129de"}]}},
          {"doc", {[{"_id", "doc_id_2"}, {"_rev", "1-59414e77c768bc202142ac82c2f129de"}, {"key", "value"}]}}
        ]
      }
    ]

    assert  %{
              "doc" => %{"_id" => "doc_id_1", "_rev" => "1-59414e77c768bc202142ac82c2f129de", "key" => "value"},
              "id" => "doc_id_1",
              "key" => "doc_id_1",
              "value" => %{"rev" => "1-59414e77c768bc202142ac82c2f129de"}
            }
            == resp |> Mapper.list_to_map |> hd
  end

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
