require 'ffi-rzmq'
require 'msgpack'

require_relative 'advertised'
require_relative 'multilingual'

module Socialite

  include Advertiser
  include Multilingual

  attr_reader :host, :port

  private

  def connections
    @connections ||= {}
  end

  def ctx
    self.class.instance_eval do
      return @ctx ||= ZMQ::Context.new(1)
    end
  end

  def bind_random host='0.0.0.0'
    100.times do 
      # catch bind exceptions, just try again
      port = Random.rand 2000...8000
      return bind(host, port) rescue "Bad Bind: #{port}"
    end
    raise "Could not find port to bind to"
  end

  def bind host, port
    @in_connection = ctx.socket ZMQ::PAIR
    #socket.setsockopt ZMQ::LINGER, 1
    @in_connection.bind "tcp://#{host}:#{port}"
    poller.register(@in_connection, ZMQ::POLLIN)
    @host, @port = host, port
    return @in_connection
  end

  def unbind
    @in_connection.close
  end

  def connection name
    return connections[name] if connections.include? name
    celf = self
    addr = find name
    raise "Could not find #{name}" if addr.nil?
    connection = connect *addr
    return if connection.nil?
    shadow = connection.instance_eval {class << self; self; end;}
    shadow.instance_eval do
      define_method :cleanup do
        celf.instance_eval do 
          connections.delete name if connections[name] == self 
        end
        connection.close rescue "Bad connection close"
      end
    end
    connections[name] = connection
    return connection
  end

  def connect host='127.0.0.1', port
    socket = ctx.socket ZMQ::PAIR
    #socket.setsockopt ZMQ::LINGER, 1
    socket.connect "tcp://#{host}:#{port}"
    poller.register(socket, ZMQ::POLLIN)
    return socket
  end

  def push name, data, do_retry=true
    # send the data to an obj matching the name
    conn = connection name
    to_send = serialize data
    begin
      conn.send_string to_send, ZMQ::NOBLOCK
    rescue => ex
      conn.cleanup
      if do_retry
        push name, data, false
      else
        raise ex
      end
    end
  end

  def poller
    @poller ||= ZMQ::Poller.new
  end

  def pop
    poller.poll 1000
    poller.readables.each do |conn|
      begin
        message = ""
        conn.recv_string message
        return deserialize message
      rescue => ex
        conn.cleanup
        raise ex
      end
    end
    return nil
  end

end
