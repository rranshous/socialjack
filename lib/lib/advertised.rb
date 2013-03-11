require 'dnssd'
require 'monitor'
require 'timeout'

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
    results = []
    results.extend MonitorMixin
    empty_cond = results.new_cond
    s = DNSSD.resolve(get_object_name(name), service_type, domain) do |reply|
      puts "FOUND: #{reply.name} :: #{reply.target}:#{reply.port}"
      results.synchronize do
        results << [reply.target, reply.port]
        empty_cond.signal
      end
      next if reply.flags.more_coming?
      return 
    end
    # wait for one of the threaded resolvers to find what we want
    # or a timeout
    results.synchronize do
      Timeout::timeout(2) { 
        empty_cond.wait_while { results.empty? }
      } rescue Timeout::Error
    end
    #s.stop unless s.stopped?
    raise "Could not stop resolver" unless s.stopped?
    return results[0] unless results.empty?
    return nil
  rescue => ex
    puts "EXCEPTION finding name: #{ex}"
    raise ex
  end
end
