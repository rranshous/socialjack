require_relative 'wiredobject'

# TODO: return passed args, verify they came back correctly
class ZMQ::Socket
  def connect t
    true
  end
  def bind t
    true
  end
  def recv_string *args
    true
  end
  def send_string d
    true
  end
end

class TestObject
  include Socialite
end

d1 = {"test"=>1}
host = '127.0.0.1'
port = 2000

describe Socialite, "#wired" do

  def obj 
    TestObject.new
  end

  it "listens for new connections" do
    obj.instance_eval do
      bind host, port
    end
  end

  it "listens for new connections on random port" do
    obj.instance_eval do
      bind_random
    end
  end

  it "connects to another wired object" do
    obj.instance_eval do
      connect host, port
    end
  end

  it "sends message to another wired object" do
    obj.instance_eval do 
      push 'testobj', d1
    end
  end

  it "receives message from another wired object" do
    obj.instance_eval do 
      pop
    end
  end
end


