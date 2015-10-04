require_relative '../lib/socialjack'

class ChatClient
  include Socialite
  def initialize name
    bind_random
    advertise port, name
  end
  def send to, msg
    push to, msg
  end
  def cycle
    message = pop
    puts "R: #{message}" if message
  end
end

client = ChatClient.new(ARGV.shift)
loop do
  client.cycle
  client.send(*gets.split(' ', 2))
end
