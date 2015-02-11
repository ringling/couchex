defmodule Integration.ServerTest do
  use ExUnit.Case
  use ShouldI, async: true

  with "server" do

    setup context do
      Dict.put context, :server, TestHelper.server
    end

    should "contain couchdb key", context do
      {:ok, info} = Couchex.server_info(context.server)
      assert info |> Map.has_key?("couchdb")
    end

    should "get all dbs", context do
      {:ok, all_dbs} = Couchex.all_dbs(context.server)
      assert Enum.member?(all_dbs, "_users")
    end

    should "get uuid", context do
      uuid = Couchex.uuid(context.server)
      assert is_binary(uuid)
    end

    should "get multiple uuids", context do
      uuids = Couchex.uuids(context.server, 3)
      assert length(uuids) == 3
    end

    should "get config", context do
      {:ok, config} = Couchex.get_config(context.server)
      assert config |> Map.has_key?("admins")
    end

    should "return server_url", context do
      server_url = Couchex.server_url(context.server)
      assert TestHelper.server_url == server_url
    end

  end

end