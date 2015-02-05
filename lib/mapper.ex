defmodule Mapper do

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
