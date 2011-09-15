require 'test/unit'
require 'socket'
require 'cwgem-selectserver'

class TestSelectServer < Test::Unit::TestCase

  def test_bind_to_port
    server = Cwgem::SelectServer.new("127.0.0.1", 8555)
    assert_raise(Errno::EADDRINUSE) do
        other_server = TCPServer.new "127.0.0.1", 8555
    end
    server.shutdown_handler
  end

  def test_no_handler
    server = Cwgem::SelectServer.new("127.0.0.1", 8555)
    assert_raise(ArgumentError) do
      server.start
    end
    server.shutdown_handler
  end

  def test_instance_method_handler
    check_server "select_server_instance_method_handler.rb", 8555
  end

  def test_global_method_handler
    check_server "select_server_global_method_handler.rb", 8555
  end

  def test_block_handler
    check_server "select_server_block_handler.rb", 8555
  end

  def check_server(server_filename, port)
    server_cmd = File.dirname(File.expand_path(__FILE__)) << "/#{server_filename} #{port}"
    pipe = IO.popen(server_cmd)
    # Sleep for 2 seconds to let the server bind
    sleep 2

    client = TCPSocket.new("localhost", port)
    client.puts "Client Data"
    data = client.gets
    assert_equal(data, "Client Data\n")
    client.close
    
    ensure
      # Be safe and send the server a shutdown signal
      # in case the socket communication fails
      Process.kill("USR1", pipe.pid)
  end

end
