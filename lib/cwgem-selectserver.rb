require 'socket'

module Cwgem
  # @author Chris White
  class SelectServer < ::TCPServer

    # Setups up the server by binding to the host and port, adding the server
    # socket to the list of sockets to check for, and initializing the
    # client socket handler and server_active (used as a main loop check) variables
    #
    # @param [String] The host to bind to
    # @param [Integer] The port to bind to
    def initialize(host,port)
      super
      @sockets = [self]
      @handler = nil
      @server_active = true
    end

    # Sets a method based handler for the main server loop
    # 
    # @param [Object] Any object that can respond to .call
    def setup_method_handler(method_handler)
      @handler = method_handler
    end

    # The main server loop. ArgumentError is raised if a handler is not set.
    #
    # @param [Object] If a block is given, it will be called with the server and client socket as arguments
    def start(&block)
      raise ArgumentError, "method handler must be set or block must be given" if 
        (!@handler or !@handler.respond_to?(:call)) and !block_given?

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

    # Accept a client socket and add it to the list of active
    # sockets
    def accept_client
      client = self.accept
      @sockets << client
    end

    # Remove a client socket from the list of active sockets
    #
    # @param [TCPSocket] The client socket to remove
    def remove_client(client_socket)
      @sockets.reject! { | socket | socket == client_socket }
    end

    # This sets a flag which will halt the main loop. The purpose of this method
    # is to allow the main loop to finish its tasks before shutting everything
    # down
    def shutdown_server
      @server_active = false
    end

    # Now that the server's main loop has finished processing, shutdown
    # the server
    def shutdown_handler
      self.close unless self.closed?
      @sockets = []
    end

  end #end class SelectServer

end
