ExUnit.start()

defmodule TestHelper do
  def server do
    Couchex.server_connection(server_url, [{:basic_auth, {"thomas", "secret"}}])
  end

  def server_url do
    "http://localhost:5984"
  end
end