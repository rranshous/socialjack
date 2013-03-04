require_relative 'advertised'

class TestObject
  include Advertiser
end

describe Advertiser, "#advertiser" do
  def obj 
    TestObject.new
  end

  it "advertises" do
    obj.instance_eval do
      advertise 'testobj'
    end
  end

  it "finds" do
    obj.instance_eval do
      find 'testobj'
    end
  end
end
