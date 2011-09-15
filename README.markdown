## Getting Started ##

A basic select multiplexing based TCP server. Client connections are handled by a method handler or a block handler. The basic format for handlers is:

```ruby
def handler(server, client_socket)
end

server = Cwgem::SelectServer.new("localhost", 3555)
server.setup_method_handler(method(:handler))
server.start
```

Where server is the server object itself, and client socket is the socket of the client. The server is passed in so you can do things like shutding down the server based on a client command:

```ruby
def handler(server,client_socket)
  command = client_socket.gets
  server.shutdown if command.chomp! == "exit"
end

server = Cwgem::SelectServer.new("localhost", 3555)
server.setup_method_handler(method(:handler))
server.start
```

Blocks can also be used as client connection handlers:

```ruby
server = Cwgem::SelectServer.new("localhost", 3555)
server.start do | server, client_socket |
end
```

Note that either a method handler must be setup before calling server.start, or a block passed into it. Failure to do so will result in an ArgumentError:

```ruby
server = Cwgem::SelectServer.new("localhost", 3555)
server.start # this will throw ArgumentError since no handler is setup
```

If you need to carry around extra metadata for client connections, the best method is to override the accept method and extend the socket through a module. In this example the client socket has a username attribute added to it by extending a ChatClient module.

```ruby
module ChatClient
  attr_accessor :username
end

server = Cwgem::SelectServer.new("localhost", 3555)
def server.accept
  client = self.accept
  client.extend(ChatClient)
  @sockets << client
end

server.start do | server, socket |
  1
end
```

## Example ##

This example is an embedded ruby script that can be run using `ruby -x Readme.markdown`. It binds to localhost on port 3555, and acts as a simple echo server. The simple server can be shutdown by sending the USR1 signal `kill -USR1 [processid]`.

```ruby
#! ruby

require 'cwgem-selectserver'

server = Cwgem::SelectServer.new("localhost", 3555)
Signal.trap("USR1") { server.shutdown; server.shutdown_handler; exit }
server.start do | server, socket |
  data = socket.gets
  socket.write data
end
__END__
```
