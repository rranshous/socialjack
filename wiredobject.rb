require 'zmq'
require 'msgpack'

require_relative 'advertised'
require_relative 'multilingual'

def error_check(rc)
  if ZMQ::Util.resultcode_ok?(rc)
    false
  else
    STDERR.puts "Operation failed, errno [#{ZMQ::Util.errno}] description [#{ZMQ::Util.error_string}]"
    caller(1).each { |callstack| STDERR.puts(callstack) }
    true
  end
end

module WiredObject

  include Advertiser
  include Multilingual

  attr_accessor :name, :host, :port

  private

  def connections
    @connections ||= {}
  end

  def ctx
    self.class.instance_eval do
      return @ctx ||= ZMQ::Context.new(1)
    end
  end

  def bind_random host='127.0.0.1'
    100.times do 
      # catch bind exceptions, just try again
      port = Random.rand 2000...8000
      return bind(host, port) rescue "Bad Bind: #{port}"
    end
    raise "Could not find port to bind to"
  end

  def bind host, port
    socket = ctx.socket ZMQ::PAIR
    socket.setsockopt ZMQ::LINGER, 1
    socket.bind "tcp://#{host}:#{port}"
    @host, @port = host, port
    return socket
  end

  def connection name
    return connections[name] if connections.include? name
    celf = self
    connection = connect *(find name)
    shadow = connection.instance_eval {class << self; self; end;}
    shadow.instance_eval do
      define_method :cleanup do
        celf.instance_eval do connections.delete name if connections[name] == self end
        connection.close rescue "Bad connection close"
      end
    end
    return connection
  end

  def connect host='127.0.0.1', port
    socket = ctx.socket ZMQ::PAIR
    socket.setsockopt ZMQ::LINGER, 1
    socket.connect "tcp://#{host}:#{port}"
    return socket
  end

  def push name, data, do_retry=true
    # send the data to an obj matching the name
    conn = connection name
    to_send = serialize data
    begin
      conn.send_string to_send 
    rescue => ex
      conn.cleanup
      if do_retry
        push name, data, false
      else
        raise ex
      end
    end
  end

  def pop
    if conn = ZMQ.select(connections.values, nil, nil, 1)
      begin
        return conn.recv_string
      rescue => ex
        conn.cleanup
        raise ex
      end
    end
    return nil
  end

end
