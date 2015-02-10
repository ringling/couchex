defmodule Mapper do

  def list_to_map(tuple_list) do
    tuple_list |> Enum.reduce(%{}, fn({k,v}, acc)-> tuple_to_map({k,v}, acc) end)
  end

  defp tuple_to_map({k,v}, map) when is_tuple(v), do: map |> Map.put(k,tuple_to_map(v, %{}))
  defp tuple_to_map({k,v}, map),                  do: map |> Map.put(k, parse_value(v))

  defp parse_value(v) when is_list(v),  do: v |> Enum.map(fn(val)-> parse_value(val) end)
  defp parse_value(v) when is_tuple(v), do: tuple_to_map(v, %{})
  defp parse_value(v),                  do: v

  def map_to_list({k,v}),                   do: [{k, v}]
  def map_to_list(map) when is_map(map),    do: reduce(map)
  def map_to_list(list) when is_list(list), do: list |> Enum.map(fn(v)-> map_to_list(v) end)
  def map_to_list(v) when is_binary(v),     do: v
  def map_to_list(v) when is_number(v),     do: v
  def map_to_list([]),                      do: []

  def reduce(map) do
    map |> Enum.reduce([], fn({k,v}, acc) -> [{k, map_to_list(v)}] ++ acc end)
  end

end
