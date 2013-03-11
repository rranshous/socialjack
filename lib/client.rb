require 'dnssd'  
browser = DNSSD::Service.new  
puts "Browsing for Agent service"  
browser.browse '_agent._tcp' do |reply|  
  puts "Time: #{Time.new.to_f} reply: #{reply.fullname}"  
  puts reply    
  break  
end 
