require_relative 'multilingual'

class TestObject
  include Multilingual
end

def d1; {"test"=>1}; end
def d1s; "\x81\xA4test\x01"; end

describe Multilingual, "#multilingual" do

  def obj
    TestObject.new
  end

  it "serializes" do
    t = self
    obj.instance_eval do
      serialize(d1).should t.eq(d1s)
    end
  end

  it "deserializes" do
    t = self
    obj.instance_eval do
      deserialize(d1s).should t.eq(d1)
    end
  end

  it "serialize nad deserializes" do
    t = self
    obj.instance_eval do
      deserialize(serialize(d1)).should t.eq(d1)
    end
  end

end

