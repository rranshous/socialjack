require 'dnssd'  
domains = []  
enumerator = DNSSD.enumerate_domains do |reply|  
  domains << reply.domain  
  puts "Found domains:\n#{domains.join "\n"}"  
  next if reply.flags.more_coming?  
  break  
end  
DNSSD.register 'agent', '_agent._tcp', nil, 6464  
puts "registered agent at 6464"  
loop do  
  sleep 1  
  puts "agent running.."  
end 
