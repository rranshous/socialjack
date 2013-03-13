require 'ffi-rzmq'
require 'msgpack'
require 'socketeer'

require_relative 'advertised'
require_relative 'multilingual'

module Socialite

  include Advertiser
  include Multilingual
  include Socketeer

  attr_reader :host, :port

  private

  def handle_message message
    # we received an incoming message
    (@message_queue ||= Queue.new) << message
  end

  def connections
    @connections ||= {}
  end

  def bind_random host='0.0.0.0'
    100.times do 
      # catch bind exceptions, just try again
      port = Random.rand 2000...8000
      return bind(host, port) rescue "Bad Bind: #{port}"
    end
    raise "Could not find port to bind to"
  end

  def connection_id name
    return connections[name] if connections.include? name
    celf = self
    addr = find name
    raise "Could not find #{name}" if addr.nil?
    connection = connect *addr
    return if connection.nil?
    conn_id = register_socket connection
    connections[name] = conn_id
    return conn_id
  end

  def connect host='127.0.0.1', port
    socket = TCPSocket host, port
    return socket
  end

  def push name, data, do_retry=true
    send_message connection_id(name), data
  end

  def pop
    cycle
    return if @message_queue.nil?
    begin
      @message_queue.deq true
    rescue ThreadError
      nil
    end
  end

end
