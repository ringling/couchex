defmodule Couchex do

  @moduledoc """
  Wrapper around the [couchbeam](https://github.com/benoitc/couchbeam/) erlang couchdb client
  """

  @doc """
  server = Couchdb.server_connection("url") #=> {:server, "url", []}

  server = Couchdb.server_connection(@couchdb_url, [{:basic_auth, {"username", "password"}}]) #=> {:server, "url", [{:basic_auth, {"username", "password"}}]}
  """
  def server_connection do
    :couchbeam.server_connection("http://localhost:5984", [])
  end
  def server_connection(url, options \\ []) do
    :couchbeam.server_connection(url, options)
  end

  @doc """
  { :ok, version } = Couchdb.server_info(server)
  """
  def server_info(server) do
    :couchbeam.server_info(server)
  end

  @doc """
  {:ok, db} = Couchdb.open_db(server, "db_name")
  """
  def open_db(server, db_name, options \\ []) do
    :couchbeam.open_db(server, db_name, options)
  end

  def create_db(server, db_name, options \\ []) do
    :couchbeam.create_db(server, db_name, options)
  end

  def save_doc(db, doc) do
    :couchbeam.save_doc(db, doc)
  end

  def open_doc(db, id) do
    :couchbeam.open_doc(db, id)
  end

  def open_doc(db, id, rev) do
    :couchbeam.open_doc(db, id, [{:rev, rev}])
  end

  def all(db, options \\ [:include_docs]) do
    :couchbeam_view.all(db, options)
  end

  def follow_once(db, options \\ []) do
    :couchbeam_changes.follow_once(db, options)
  end

  def follow(db, options \\ []) do
    :couchbeam_changes.follow(db, options)
  end

  def fetch_view(db, {design_name, view_name}, options \\ []) do
    :couchbeam_view.fetch(db, {design_name, view_name}, options)
  end

end

