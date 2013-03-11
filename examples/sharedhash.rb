require_relative '../lib/socialjack'

class SharedHash
  include Socialite

  def initialize name, hash
    @hash = hash
    @name = name
  end

  def go_public
    bind_random
    advertise port
  end

  def cycle
    while message = pop
      case message['type']
      when 'initial', 'updated'
        o_hash = @hash.dup
        @hash = message['data'].merge @hash
        broadcast_update unless @hash == o_hash
      else
        raise "Unrecignized message type: #{message['type']}"
      end
      puts "HASH: #{@hash}"
    end
  end

  def share_with *args
    @friends ||= []
    @friends = @friends + args
  end

  def broadcast_initial
    return unless @friends
    @friends.each do |f|
      begin
        push f, 'type'=>'initial',
                'data'=>@hash
      rescue
        puts "Could not find"
      end
    end
  end

  def broadcast_update
    return unless @friends
    @friends.each do |f|
      begin
        push f, 'type'=>'updated',
                'data'=>@hash
      rescue
        puts "Could not find"
      end
    end
  end

  def merge new_hash
    @hash.merge! new_hash
    broadcast_update
  end

end

if __FILE__ == $0
  name, *friends = ARGV
  hash = {}
  shared_hash = SharedHash.new name, hash
  shared_hash.share_with *friends
  shared_hash.go_public
  shared_hash.broadcast_initial
  loop do
    shared_hash.cycle
    sleep Random.rand 10
    shared_hash.merge({ Random.rand(1000) => 1 })
    shared_hash.broadcast_update
  end
end
