require 'test/unit'
require 'daemon_proxy'
require 'CGI'


class XmlRpcTest < Test::Unit::TestCase
  # def setup
  # end

  # def teardown
  # end

  def test_xml_rpc
    proxy = make_daemon_proxy("http://localhost:2000")

    assert_equal "\\", proxy.backslash()
    #assert_equal ["x"], proxy.listVariables()
    #assert_equal 1, proxy.remVariable('x')
    #assert_equal [], proxy.listVariables()
    #assert_equal , proxy.assign('lambda y:y**2','x')
    #assert_raise(XMLRPC::FaultException){ proxy.eval('x(x(2))') }
  end
end

