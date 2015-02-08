defmodule Integration.ServerTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, server: TestHelper.server}
  end

  test "server info has couchdb key", %{server: server} do
    {:ok, info} = Couchex.server_info(server)
    assert info |> Map.has_key?("couchdb")
  end

  test "get all dbs", %{server: server} do
    {:ok, all_dbs} = Couchex.all_dbs(server)
    assert Enum.member?(all_dbs, "_users")
  end

  test "get uuid", %{server: server} do
    [uuid] = Couchex.uuid(server)
    assert is_binary(uuid)
  end

  test "get multiple uuids", %{server: server} do
    uuids = Couchex.uuids(server, 3)
    assert length(uuids) == 3
  end

  test "get config", %{server: server} do
    {:ok, config} = Couchex.get_config(server)
    assert config |> Map.has_key?("admins")
  end

  test "server_url", %{server: server} do
    server_url = Couchex.server_url(server)
    assert TestHelper.server_url == server_url
  end

end