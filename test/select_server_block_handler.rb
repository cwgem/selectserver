#!/usr/bin/env ruby

require 'cwgem-selectserver'

port = ARGV[0].to_i
server = Cwgem::SelectServer.new("localhost", port)
Signal.trap("USR1") { server.shutdown; server.shutdown_handler; exit }
server.start do | server, socket |
  data = socket.gets
  socket.write data
  server.shutdown
end
