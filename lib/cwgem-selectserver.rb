require 'socket'

module Cwgem

  class SelectServer < ::TCPServer

    def initialize(host,port)
      super
      @sockets = [self]
      @handler = nil
      @server_active = true
    end

    def setup_method_handler(method_handler)
      @handler = method_handler
    end

    def start(&block)
      raise ArgumentError, "method handler must be set or block must be given" if !@handler and !block_given?
      @handler = block if block_given?

      while @server_active == true
        readable_sockets,writable_sockets,exception_sockets = IO.select(@sockets,[], @sockets)

        readable_sockets.each do | read_socket |
          if read_socket == self
            accept_client
          elsif read_socket.closed? or read_socket.eof?
            exit if read_socket == self
            remove_client read_socket
          else
            @handler.call(self,read_socket)
          end
        end

        exception_sockets.each do | err_socket |
          remove_client err_socket
        end

      end

      shutdown_handler
    end

    def accept_client
      client = self.accept
      @sockets << client
    end

    def remove_client(client_socket)
      @sockets.reject! { | socket | socket == client_socket }
    end

    def shutdown_server
      @server_active = false
    end

    def shutdown_handler
      self.close
      @sockets = []
    end

  end #end class SelectServer

end
