# Couchex

Elixir wrapper around the [couchbeam](https://github.com/benoitc/couchbeam/) Erlang CouchDB client

2015 (c) Thomas Ringling

See iex help @doc, for usage info


## Installation

First, add Couchex to your `mix.exs` dependencies:

```elixir
def deps do
  [{:couchex, "~> 0.8"}]
end
```

Then, update your dependencies:

```sh-session
$ mix deps.get
```

## Tests

To run integration tests, add a user `test/test` on localhost:5984 couch server

## Couchbeam


2009-2015 (c) Benoitît Chesneau <benoitc@e-engura.org>

couchbeam is released under the MIT license. See the [LICENSE](https://github.com/benoitc/couchbeam/blob/master/LICENSE) file for the
complete license.


### couchbeam:couchbeam_deps

Copyright  2007-2008 Basho Technologies

## Not implemented :couchbeam functions

* copy_doc/2
* copy_doc/3
* create_db/4
* delete_attachment/4
* delete_doc/2
* delete_docs/3
* doc_url/2
* end_doc_stream/1
* ensure_full_commit/1
* ensure_full_commit/2
* fetch_attachment/3
* fetch_attachment/4
* get_missing_revs/2
* lookup_doc_rev/2
* lookup_doc_rev/3
* module_info/0
* module_info/1
* open_doc/2
* open_doc/3
* open_or_create_db/2
* open_or_create_db/3
* open_or_create_db/4
* put_attachment/4
* put_attachment/5
* replicate/3
* replicate/4
* save_doc/3
* save_doc/4
* save_docs/2
* save_docs/3
* send_attachment/2
* server_connection/0
* server_connection/1
* server_connection/2
* server_connection/4
* server_url/1
* start/0
* stop/0
* stream_attachment/1
* stream_doc/1
* version/0
