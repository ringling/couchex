defmodule Couchex do

  @moduledoc """
  Wrapper around the [couchbeam](https://github.com/benoitc/couchbeam/) erlang couchdb client
  """

  @doc """
  Returns a server connection

  ## Examples

      Couchex.server_connection("url")
      #=> {:server, "url", []}

      Couchex.server_connection(@couchdb_url, [{:basic_auth, {"username", "password"}}])
      #=> {:server, "url", [{:basic_auth, {"username", "password"}}]}
  """
  def server_connection, do: server_connection("http://localhost:5984")
  def server_connection(url, options \\ []) do
    :couchbeam.server_connection(url, options)
  end

  @doc """
  Returns basic info about server

  ## Examples
      Couchex.server_info(server)
      #=> %{"couchdb" => "Welcome", "uuid" => "c1cdba4b7d7a963b9ca7c5445684679f", "vendor" => {[{"version", "1.5.0-1"}, {"name", "Homebrew"}]}, "version" => "1.5.0"}
  """
  def server_info(server) do
    :couchbeam.server_info(server)
    |> map_response
  end

  @doc """
  Replicates a database from source to target

  ## Examples

  `create_target` param, target db is created if not already present

  `continuous` param, replication runs continuously until server restart

      Couchex.replicate(server, %{source: "sourcedb", target: "targetdb", create_target: true})
      #=> {:ok, %{"history" => [...], "ok" => true, "replication_id_version" => 3, "session_id" => "b3457b342b2eb31ea0f85e77bac03a66", "source_last_seq" => 16}}

      Couchex.replicate(server, %{source: "https://user:pass@sourcedb", target: "targetdb", create_target: true})
      #=> {:ok, resp}

      Couchex.replicate(server, %{source: "https://user:pass@sourcedb", target: "http://user:pass@targetdb", create_target: true})
      #=> {:ok, resp}

      Couchex.replicate(server, %{source: "https://user:pass@sourcedb", target: "http://user:pass@targetdb", create_target: true, continuous: true})
      #=> #=> {:ok, %{"Cache-Control" => "must-revalidate", "Content-Length" => "84", "Content-Type" => "application/json", "Date" => "Mon, 09 Feb 2015 16:24:19 GMT", "Server" => "CouchDB/1.5.0 (Erlang OTP/R16B03)"}}

  """
  def replicate(server, rep_obj) do
    :couchbeam.replicate(server, {rep_obj |> Map.to_list})
    |> map_response
  end

  @doc """
  Returns a list of all databases

  ## Examples

      Couchex.all_dbs(server)
      #=> {:ok, ["_replicator", "_users", "some_db", ...]}
  """
  def all_dbs(server) do
    :couchbeam.all_dbs(server)
  end

  @doc """
  Returns a single server generated uuid

  ## Examples
      Couchex.uuid(server)
      #=> "267732468d85b6fd22504aeaa4dc68e3"
  """
  def uuid(server) do
    [uuid] = :couchbeam.get_uuid(server)
    uuid
  end

  @doc """
  Returns a total of `number` server generated uuids

  ## Examples
      Couchex.uuids(server, 3)
      #=> ["267732468d85b6fd22504aeaa4fb8ac9", "267732468d85b6fd22504aeaa4fb8065", "267732468d85b6fd22504aeaa4fb7ca7"]
  """
  def uuids(server, number) do
    :couchbeam.get_uuids(server, number)
  end

  @doc """
  Opens a database

  If credentials were passed during server_connection, they will be passed on to open_db.
  They will however be overwritten by the credentials applied to open_db

  ## Examples
      Couchex.open_db(server, "couchex")
      #=> {:ok, {:db, server, "couchex", []}}

      Couchex.open_db(server, "couchex", [{:basic_auth, {"username", "password"}}])
      #=> {:ok, {:db, server, "couchex", [{:basic_auth, {"username", "password"}}]}}
  """
  def open_db(server, db_name, options \\ []) do
    :couchbeam.open_db(server, db_name, options)
  end

  @doc """
  Creates a database. The database must NOT exist

  ## Examples
      Couchex.create_db(server, "couchex")
      #=> {:db, server, "couchex", [basic_auth: {"username", "password"}]}}
      Couchex.create_db(server, "couchex")
      #=> {:error, :db_exists}
  """
  def create_db(server, db_name, options \\ []) do
    :couchbeam.create_db(server, db_name, options)
  end

  @doc """
  Deletes a database. The database must exist

  ## Examples
      {:ok, db} = Couchex.open_db(server, "couchex")
      #=> {:ok, {:db, server, "couchex", []}}
      Couchex.delete_db(db)
      #=> {:ok, :db_deleted}
      Couchex.delete_db(db)
      #=> {:error, :not_found}
  """
  def delete_db(db) do
    case :couchbeam.delete_db(db) |> map_response do
      {:ok, %{"ok" => true}} -> {:ok, :db_deleted}
      response -> response
    end
  end

  @doc """
  Deletes a database. The database must exist

  ## Examples
      Couchex.delete_db(server, "couchex")
      #=> {:ok, :db_deleted}
      Couchex.delete_db(server, "couchex")
      #=> {:error, :not_found}
  """
  def delete_db(server, db_name) do
    case :couchbeam.delete_db(server, db_name) |> map_response do
      {:ok, %{"ok" => true}} -> {:ok, :db_deleted}
      response -> response
    end
  end

  @doc """
  Returns database info.

  ## Examples
      {:ok, db} = Couchex.open_db(server, "couchex")
      Couchex.db_info(db)
      #=> %{"committed_update_seq" => 0, "compact_running" => false, "data_size" => 227,
          "db_name" => "couchex", "disk_format_version" => 6, "disk_size" => 306,
          "doc_count" => 1, "doc_del_count" => 0,
          "instance_start_time" => "1423503379138489", "purge_seq" => 0,
          "update_seq" => 1}
  """
  def db_info(db) do
    :couchbeam.db_info(db) |> map_response
  end

  @doc """
  Compacts a database.

  [Wiki](https://wiki.apache.org/couchdb/Compaction)

  ## Examples
      {:ok, db} = Couchex.open_db(server, "couchex")
      Couchex.compact(db)
      #=> :ok
  """
  def compact(db) do
    :couchbeam.compact(db)
  end

  @doc """
  Compacts the view index.

  [Wiki](https://wiki.apache.org/couchdb/Compaction#View_compaction)

  ## Examples

      {:ok, db} = Couchex.open_db(server, "couchex")
      Couchex.compact(db, "design_name")
      #=> :ok
  """
  def compact(db, design_name) do
    :couchbeam.compact(db, design_name)
  end

  @doc """
  Checks if database exist.

  ## Examples
      Couchex.db_exists?(server, "couchex")
      #=> true
  """
  def db_exists?(server, db_name) do
    :couchbeam.db_exists(server, db_name)
  end

  @doc """
  Save and update a document

  Update a document, by using an existing document id

  Please remark the use of `%{"_id" => "ID", ...}` and not `%{"_id": "ID", ...}`, the latter will not work

  ## Examples
      Couchex.save_doc(db, %{"key" => "value"}) # Couch auto creates id
      #=> %{"_id" => "c1cdba4b7d7a963b9ca7c5445684679f", "_rev" => "1-59414e77c768bc202142ac82c2f129de", "key" => "value"}

      Couchex.save_doc(db, %{"_id" => "FIRST_ID", "key" => "value"}) # User defined id
      #=> %{"_id" => "FIRST_ID", "_rev" => "1-59414e77c768bc202142ac82c2f129de", "key" => "value"}
  """
  def save_doc(db, doc) do
    :couchbeam.save_doc(db, {Mapper.map_to_list(doc)})
    |> map_response
  end

  @doc """
  Returns true if document exists

  ## Examples

      Couchex.doc_exists?(db, "EXISTING_DOC_ID")
      #=> true

      Couchex.doc_exists?(db, "NONE_EXISTING_DOC_ID")
      #=> false

  """
  def doc_exists?(db, doc_id) do
    :couchbeam.doc_exists(db, doc_id)
  end

  @doc """
  Put an attachment to document

  ## Examples
      attachment = %{ name: "image.png", data: "....", content_type: "image/png" }
      Couchex.put_attachment(db, %{id: id}, attachment) # latest revision
      #=> {:ok, %{"id" => "18c359e463c37525e0ff484dcc0003b7", "rev" => "3-ebe18f0e4f4c3c717a9e9291bc2465b3"}}

      doc_id = "18c359e463c37525e0ff484dcc0003b7"
      revision = "1-59414e77c768bc202142ac82c2f129de"
      content_type = Couchex.MIME.type("txt") # => "text/plain"
      attachment = %{ name: "file.txt", data: "SOME DATA - HERE IT'S TEXT", content_type: content_type }
      Couchex.put_attachment(db, %{id: doc_id, rev: revision}, attachment)
      #=> {:ok, %{"id" => "18c359e463c37525e0ff484dcc0003b7", "rev" => "3-ebe18f0e4f4c3c717a9e9291bc2465b3"}}
  """
  def put_attachment(db, %{id: id, rev: rev}, attachment) do
    _put_attachment(db, id, attachment, [{:rev, rev}, {:content_type, attachment.content_type}])
  end
  def put_attachment(db, %{id: id}, attachment) do
    {:ok, rev} = lookup_doc_rev(db, id)
    _put_attachment(db, id, attachment, [{:rev, rev}, {:content_type, attachment.content_type}])
  end
  defp _put_attachment(db, doc_id, attachment, options) do
    :couchbeam.put_attachment(db, doc_id, attachment.name, attachment.data, options)
    |> map_response
  end

  @doc """
  Fetch attachment from document

  ## Examples
      doc_id = "18c359e463c37525e0ff484dcc0003b7"
      attachment_name = "file.txt"
      Couchex.fetch_attachment(db, doc_id, attachment_name)
      #=> {:ok, "SOME DATA - HERE IT'S TEXT"}

  """
  def fetch_attachment(db, doc_id, attachment_name) do
    :couchbeam.fetch_attachment(db, doc_id, attachment_name)
  end

  @doc """
  Delete attachment from document

  This method is idempotent, and will increment the document revision, even though the attachment isn't present(e.g. already deleted)

  ## Examples
      attachment_name = "file.txt"

      Couchex.delete_attachment(db, %{id: "18c359e463c37525e0ff484dcc0003b7"}, attachment_name)
      #=> {:ok, %{"id" => "18c359e463c37525e0ff484dcc0003b7", "rev" => "4-ebe18f0e4f4c3c717a9e9291bc2465b3"}}

      Couchex.delete_attachment(db, %{id: "18c359e463c37525e0ff484dcc0003b7", rev: "3-ebe18f0e4f4c3c717a9e9291bc2465b3"}, attachment_name)
      #=> {:ok, %{"id" => "18c359e463c37525e0ff484dcc0003b7", "rev" => "4-ebe18f0e4f4c3c717a9e9291bc2465b3"}}
  """
  def delete_attachment(db, %{id: id, rev: rev}, attachment_name) do
    :couchbeam.delete_attachment(db, id, attachment_name, [{:rev, rev}])
    |> map_response
  end
  def delete_attachment(db, %{id: id}, attachment_name) do
    {:ok, rev} = lookup_doc_rev(db, id)
    delete_attachment(db, %{id: id, rev: rev}, attachment_name)
  end

  @doc """
  Retreives document as map, by id with or without revision

  ## Examples
      Couchex.open_doc(db, %{id: id})
      #=> {:ok, %{"_id" => id, "_rev" => rev, ...}}

      Couchex.open_doc(db, %{id: id, rev: revision})
      #=> {:ok, %{"_id" => id, "_rev" => rev, ...}}
  """
  def open_doc(db, %{id: id}) do
    :couchbeam.open_doc(db, id) |> map_open_resp
  end
  def open_doc(db, %{id: id, rev: rev}) do
    :couchbeam.open_doc(db, id, [{:rev, rev}]) |> map_open_resp
  end

  @doc """
  - CouchDB 2.0 only -
  Retreives all documents via mango query

  ## Examples
      query = %{
        "selector": %{
          "_id": %{
            "$gt": nil
          }
        }
      }
      Couchex.find(db, query)
      #=> %{ docs: [%{"_id" => "..."}, ...], warning: <ONLY IF WARNING SENT FROM SERVER> }
  """
  def find(db, query) do
    # TODO json_body response can have warning {"warning":"no matching index found, create an index to optimize query time", "docs":[]}
    ref = post_request(db, "_find", query)
    ref |> :couchbeam_httpc.json_body |> map_find_resp
  end

  @doc """
  - CouchDB 2.0 only -
  Creates an index

  ## Examples
      index = %{ "name" => "name-index", "type" => "json", "index" => %{ "fields" => [ %{ "key": "asc" } ] } }
      Couchex.create_index(db, index)
      #=> {:ok, %{id: "id", name: "name-index", status: :created}}
  """
  def create_index(db, index) do
    ref = post_request(db, "_index", index)
    ref |> :couchbeam_httpc.json_body |> map_index_resp
  end

  defp map_index_resp({[{"error", _err}, {"reason", reason}]}), do: {:error, reason}
  defp map_index_resp({[{"result", "created"}, {"id", id}, {"name", name}]}), do: {:ok, %{id: id, name: name, status: :created}}
  defp map_index_resp({[{"result", "exists"}, {"id", id}, {"name", name}]}), do: {:ok, %{id: id, name: name, status: :exists}}

  defp map_find_resp({[{"error", _err}, {"reason", reason}]}), do: {:error, reason}
  defp map_find_resp({[{"warning", warning}, {"docs", docs}]}), do: %{ docs: Mapper.list_to_map(docs), warning: warning }
  defp map_find_resp({[{"docs", docs}]}), do: %{ docs: Mapper.list_to_map(docs) }

  defp post_request(db, key, body) do
    {:db, server, _database, opts} = db
    url = :hackney_url.make_url(:couchbeam_httpc.server_url(server), :couchbeam_httpc.doc_url(db, key), [])
    headers = [{"Content-Type","application/json"}]
    {:ok, _status_code, _headers, ref} = :couchbeam_httpc.db_request(:post, url, headers, to_json(body), opts)
    ref
  end

  defp to_json(query), do: query  |> Poison.encode!

  defp map_open_resp({:error, err}), do: {:error, err}
  defp map_open_resp({:ok, resp}),   do: resp |> Mapper.list_to_map

  @doc """
  Returns current document revision

  ## Examples
      Couchex.lookup_doc_rev(db, "18c359e463c37525e0ff484dcc0003b7")
      #=> {:ok, "1-59414e77c768bc202142ac82c2f129de"}
  """
  def lookup_doc_rev(db, id) do
    :couchbeam.lookup_doc_rev(db, id) |> map_response
  end

  @doc """
  Delete a document

  ## Examples
      Couchex.delete_doc(db, %{id: "18c359e463c37525e0ff484dcc0003b7", rev: "1-59414e77c768bc202142ac82c2f129de"})
      #=> %{"id" => "18c359e463c37525e0ff484dcc0003b7", "ok" => true, "rev" => "2-9b2e3bcc3752a3a952a3570b2ed4d27e"}
  """
  def delete_doc(db, %{id: id, rev: rev}) do
    doc = {[{"_id", id}, {"_rev", rev}]}
    :couchbeam.delete_doc(db, doc, [])
    |> map_response
  end

  @doc """
  Deletes a list of documents

  ## Examples
      Couchex.delete_docs(db, [%{id: "18c359e463c37525e0ff484dcc0003b7", rev: "1-59414e77c768bc202142ac82c2f129de"}])
      #=> [%{"id" => "18c359e463c37525e0ff484dcc0003b7", "ok" => true, "rev" => "2-9b2e3bcc3752a3a952a3570b2ed4d27e"}]
  """
  def delete_docs(db, list) do
    docs = Enum.map(list, fn(doc)-> {[{"_id", doc.id}, {"_rev", doc.rev}]} end)
    {:ok, resp} = :couchbeam.delete_docs(db, docs, [])
    map_response(resp)
  end

  @doc """
  Returns all documents in a database

  ## Examples

      Couchex.all(db)
      #=> [
            %{
              "doc" => %{"_id" => "doc_id_1", "_rev" => "...", "foo" => "bar"},
              "id" => "doc_id_1",
              "key" => "doc_id_1",
              "value" => %{"rev" => "..."}
            },
            %{"doc" => %{"_id" => "doc_id_2", ...
          ]

  """
  def all(db, options \\ [:include_docs]) do
    {:ok, resp } = :couchbeam_view.all(db, options)
    resp |> Mapper.list_to_map
  end

  @doc """
  Follow database changes

  ## Examples

      def changes_fun(stream_ref) do
        receive do
          {stream_ref, {:done, last_seq}} ->
            Logger.info "Stopped at seq: \#{inspect last_seq}"
            :ok
          {stream_ref, {:change, change}} ->
            Logger.info "Change: \#{inspect change}"
            changes_fun(stream_ref)
          {stream_ref, error}->
            Log.error "\#{inspect error}"
          msg ->
            Logger.warn "\#{inspect msg}"
        end
      end

      Couchex.follow(db, [:continuous, :heartbeat])
      #=> {:ok, <stream_ref>}
      changes_fun(<stream_ref>)

  """
  def follow(db, options \\ []) do
    :couchbeam_changes.follow(db, options)
  end

  def follow_once(db, options \\ []) do
    :couchbeam_changes.follow_once(db, options)
  end

  @doc """
  Fetch view

  ## Examples

      {:ok, res} = Couchex.fetch_view(db, {"lists","company_users_by_income"},[:group])

      When having a design doc like this,

      design_doc = %{
         "_id" => "_design/lists",
         "language": "javascript",
         "views": %{
             "by_customer_id": %{
                 "map": "function(doc) {  emit(doc.customer_id, doc);}"
             }
         }
      }

      fetch docs by customer id

      {:ok, res} = Couchex.fetch_view(db, {"lists","by_customer_id"},[key: customer_id])

  """
  def fetch_view(db, {design_name, view_name}, options \\ []) do
    :couchbeam_view.fetch(db, {design_name, view_name}, options)
  end

  defp map_response({:ok, [{list}]}) when is_list(list), do: {:ok, Enum.into(list, %{})}
  defp map_response(list) when is_list(list) do
    res = list |> Enum.map(fn(t)->
        {l} = t
        Enum.into(l, %{})
      end)
    {:ok, res}
  end
  defp map_response({:ok, _status_code, resp, _ref}), do: {:ok, Enum.into(resp, %{})}
  defp map_response({:ok, {response}}), do: {:ok, response |> Enum.into(%{})}
  defp map_response({:error, response}), do: {:error, response}
  defp map_response(response), do: {:ok, response}
end
