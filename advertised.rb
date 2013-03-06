
module Advertiser

  private

  def advertise name=nil
    @name ||= name
    raise "Can not advertise w/o name" if @name.nil?
    # TODO: publish ourself as accepting connections
  end

  def find name
    # use zeroconf to find zmq endpoint
    # for the given obj name
    # TODO: actually lookup in zeroconf
    ['127.0.0.1', 2000]
  end
end
