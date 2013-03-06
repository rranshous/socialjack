require 'dnssd'

Thread.abort_on_exception = true
trap 'INT' do exit end
trap 'TERM' do exit end

module Advertiser

  private

  def advertise port, name=nil
    @name ||= name
    raise "Can not advertise w/o name" if @name.nil?
    record = DNSSD::TextRecord.new
    record["test"] = '1'
    record["success"] = '1'
    DNSSD.register "#{@name}Object", "_object._tcp", "local", port, record
  end

  def find name
    # use zeroconf to find zmq endpoint
    # for the given obj name
    puts "FIND: #{name}"
    begin
      DNSSD.resolve! "#{name}Object", "_object._tcp", "local" do |reply|
        begin
          puts "FOUND: #{reply.name} :: #{reply.target}:#{reply.port}"
          break unless reply.flags.more_coming?
          return [reply.target, reply.port]
        rescue => ex
          puts "INNER EX: #{ex}"
        end
      end
    rescue => ex
      puts "ExCEPTION finding name: #{ex}"
      raise ex
    end
    puts "FOUND NOTHING"
    nil
  end
end
