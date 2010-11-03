require 'xmlrpc/client'

class XmlRpcProxy
  def initialize(client)
    @client = client
  end

  def method_missing(name, *args)
    @client.call name, *args
  end
end

def make_daemon_proxy(uri)
  client = XMLRPC::Client.new2(uri)
  XmlRpcProxy.new(client)
end

