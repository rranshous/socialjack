require_relative 'wiredobject'

class Testeroo 
  include WiredObject
end

to_send = ARGV.shift
puts "TOSEND: #{to_send}"
unless to_send
  tester = Testeroo.new
  tester.instance_eval do
    puts 'advertising'
    puts 'binding'
    bind '127.0.0.1', 2000
    advertise 2000, 'TEST'
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
    push 'TEST', to_send
  end
end

puts "END OF EXAMPLE"
puts "Threads:"
Thread.list.each {|t| p t}
