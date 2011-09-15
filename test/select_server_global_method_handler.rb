#!/usr/bin/env ruby

require 'cwgem-selectserver'

def handle_client(server,socket)
  data = socket.gets
  socket.write data
  server.shutdown_server
end

port = ARGV[0].to_i
server = Cwgem::SelectServer.new("localhost", port)
Signal.trap("USR1") { server.shutdown_server; server.shutdown_handler; exit }
server.setup_method_handler(method(:handle_client))
server.start
