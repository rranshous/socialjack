require_relative 'wiredobject'

module Multilingual
  def serialize data
    data
  end
  def deserialize data
    data
  end
end

class Testeroo 
  include WiredObject
end


to_send = ARGV[0]
puts "TOSEND: #{to_send}"
unless to_send
  tester = Testeroo.new
  tester.instance_eval do
    puts 'binding'
    bind '127.0.0.1', 2000
  end
  tester.instance_eval do
    puts 'poping'
    loop do
      r = pop
      puts "R: #{r}" if r
    end
  end
else
  tester2 = Testeroo.new
  tester2.instance_eval do
    puts 'pushing'
    push 'arb', to_send
  end
end
