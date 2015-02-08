defmodule Couchex do

  @moduledoc """
  Wrapper around the [couchbeam](https://github.com/benoitc/couchbeam/) erlang couchdb client
  """

  @doc """
  server = Couchdb.server_connection("url") #=> {:server, "url", []}

  server = Couchdb.server_connection(@couchdb_url, [{:basic_auth, {"username", "password"}}]) #=> {:server, "url", [{:basic_auth, {"username", "password"}}]}
  """
  def server_connection, do: server_connection("http://localhost:5984")
  def server_connection(url, options \\ []) do
    :couchbeam.server_connection(url, options)
  end

  @doc """
  { :ok, version } = Couchdb.server_info(server)
  """
  def server_info(server) do
    :couchbeam.server_info(server)
    |> map_response
  end

  @doc """
  %{source: "sourcedb", target: "targetdb", create_target: true}
  """
  def replicate(server, rep_obj) do
    :couchbeam.replicate(server, {rep_obj |> Map.to_list})
    |> map_response
  end

  def all_dbs(server) do
    :couchbeam.all_dbs(server)
  end

  def server_url(server) do
    :couchbeam.server_url(server)
  end

  def get_config(server) do
    :couchbeam.get_config(server) |> map_response
  end

  def uuid(server) do
    :couchbeam.get_uuid(server)
  end

  def uuids(server, number) do
    :couchbeam.get_uuids(server, number)
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

  def delete_db(server, db_name) do
    response = :couchbeam.delete_db(server, db_name)
    |> map_response

    case response do
      {:ok, %{"ok" => true}} -> {:ok, :db_deleted}
      _ -> response
    end
  end

  def db_info(db) do
    :couchbeam.db_info(db) |> map_response
  end


  def db_url(db) do
    :couchbeam.db_url(db)
  end

  def compact(db) do
    :couchbeam.compact(db)
  end

  def db_exists?(server, db_name) do
    :couchbeam.db_exists(server, db_name)
  end

  @doc """
    doc = %{"key" => "value", ...}
  """
  def save_doc(db, doc) do
    :couchbeam.save_doc(db, {Mapper.map_to_list(doc)})
    |> map_response
  end

  def doc_exists?(db, doc_id) do
    :couchbeam.doc_exists(db, doc_id)
  end

  @doc """
    attachment = %{ name: "image.png", data: "....", content_type: "image/png" }
  """
  def put_attachment(db, doc_id, attachment) do
    {:ok, rev} = lookup_doc_rev(db, doc_id)
    put_attachment(db, doc_id, attachment, [{:rev, rev}, {:content_type, attachment.content_type}])
  end
  def put_attachment(db, doc_id, attachment, options) do
    :couchbeam.put_attachment(db, doc_id, attachment.name, attachment.data, options)
    |> map_response
  end

  def fetch_attachment(db, doc_id, attachment_name) do
    :couchbeam.fetch_attachment(db, doc_id, attachment_name)
  end

  def delete_attachment(db, doc_id, attachment_name) do
    {:ok, doc} = open_doc(db, doc_id)
    :couchbeam.delete_attachment(db, doc, attachment_name)
    |> map_response
  end

  def open_doc(db, id) do
    :couchbeam.open_doc(db, id)
    |> map_response
  end

  def lookup_doc_rev(db, id) do
    :couchbeam.lookup_doc_rev(db, id)
    |> map_response
  end

  def open_doc(db, id, rev) do
    :couchbeam.open_doc(db, id, [{:rev, rev}])
  end

  def delete_doc(db, id, rev) do
    doc = {[{"_id", id}, {"_rev", rev}]}
    {:ok, {response}} = :couchbeam.delete_doc(db, doc, [])
    |> map_response
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



  defp map_response({:ok, _status_code, resp, _ref}), do: {:ok, Enum.into(resp, %{})}

  defp map_response({:ok, {response}}), do: {:ok, response |> Enum.into(%{})}
  defp map_response({:error, response}), do: {:error, response}
  defp map_response(response), do: {:ok, response}

end

# :couchbeam functions
# x all_dbs/1               x compact/1               compact/2
# copy_doc/2              copy_doc/3              x create_db/2
# create_db/3             create_db/4             x db_exists/2
# x db_info/1               x db_url/1                x delete_attachment/3
# delete_attachment/4     delete_config/3         delete_config/4
# delete_db/1             x delete_db/2             delete_doc/2
# x delete_doc/3            delete_docs/2           delete_docs/3
# doc_exists/2            doc_url/2               end_doc_stream/1
# ensure_full_commit/1    ensure_full_commit/2    fetch_attachment/3
# fetch_attachment/4      get_config/1            get_config/2
# get_config/3            get_missing_revs/2      x get_uuid/1
# x get_uuids/2             lookup_doc_rev/2        lookup_doc_rev/3
# module_info/0           module_info/1           open_db/2
# x open_db/3               open_doc/2              open_doc/3
# open_or_create_db/2     open_or_create_db/3     open_or_create_db/4
# put_attachment/4        put_attachment/5        x replicate/2
# replicate/3             replicate/4             save_doc/2
# save_doc/3              save_doc/4              save_docs/2
# save_docs/3             send_attachment/2       server_connection/0
# server_connection/1     server_connection/2     server_connection/4
# x server_info/1           server_url/1            set_config/4
# set_config/5            start/0                 stop/0
# stream_attachment/1     stream_doc/1            version/0

