require 'msgpack'

module Multilingual

  attr_accessor :serializer, :deserializer

  private

  def serialize data
    serializer ||= proc {|d| MessagePack.pack d}
    serializer.call data
  end

  def deserialize data
    deserializer ||= proc {|d| MessagePack.unpack d}
    deserializer.call data
  end

end
