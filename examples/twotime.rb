require_relative '../lib/socialjack'

## have two objs chatting back and forth

class ChattyBot
  include Socialite
  def initialize name
    bind_random
    advertise port, name
  end
  def get_chatty talk_to=nil
    message = pop
    if message
      puts "#{@name} Overheard: #{message}"
    end
    if talk_to
      puts "#{@name} SAYING TO #{talk_to}"
      push talk_to, "My name is: #{name}"
    end
  end
end

Thread.new do
  bob = ChattyBot.new 'bob'
  while loop
    sleep(1)
    bob.get_chatty 'betty'
  end
end

Thread.new do
  betty = ChattyBot.new 'betty'
  while loop
    betty.get_chatty 'bob'
    sleep(1)
  end
end

loop do
  sleep 1
end
