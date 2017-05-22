
Add specs
---------

@type option :: {atom, {String.t, String.t}}
@type server :: {atom, String.t, list(option)}
@type database :: {atom, server, String.t, list(option)}

@spec server_info(server) :: map()
def server_info(server) do
  :couchbeam.server_info(server)
    |> map_response
end



https://github.com/benoitc/couchbeam/blob/master/doc/couchbeam_changes.md


Options :: changes_stream_options() [continuous
     | :longpoll
     | :normal
     | :include_docs
     | {:since, integer() | now}
     | {:timeout, integer()}
     | :heartbeat | {:heartbeat, integer()}
     | {:filter, string()} | {:filter, string(), list({string(), string() | integer()})}
     | {:view, string()},
     | {docids, list))},
     | {stream_to, pid()},
     | {:async, once | normal}]