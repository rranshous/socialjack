require 'dnssd'

Thread.abort_on_exception = true
trap 'INT' do exit end
trap 'TERM' do exit end

module Advertiser

  private

  def service_type
    "_object._tcp"
  end

  def domain
    "local"
  end

  def get_object_name name
    "#{name}Object"
  end

  def advertise port, name=nil
    @name ||= name
    puts "AD: #{get_object_name(@name)} :: #{port}"
    raise "Can not advertise w/o name" if @name.nil?
    record = DNSSD::TextRecord.new
    record["test"] = '1'
    record["success"] = '1'
    DNSSD.register get_object_name(@name), service_type, 
                   domain, port, record
  end

  def find name
    # use zeroconf to find zmq endpoint
    # for the given obj name
    puts "FIND: #{get_object_name(name)} :: #{service_type}"
    DNSSD.browse! service_type do |browse_reply|
      puts "BREPLY: #{browse_reply.fullname} -> #{browse_reply.inspect}"
      if (browse_reply.flags.to_i & DNSSD::Flags::Add) != 0
        # adding record
        DNSSD.resolve! browse_reply do |reply|
          begin
            puts "FOUND: #{reply.name} :: #{reply.target}:#{reply.port}"
            return [reply.target, reply.port]
            #break unless reply.flags.more_coming? ?????
          rescue => ex
            puts "INNER EX: #{ex}"
          end
        end
      else
        # removing record
      end
    end
    puts "FOUND NOTHING"
    nil
  rescue
    puts "EXCEPTION finding name: #{ex}"
    raise ex
  end
end
