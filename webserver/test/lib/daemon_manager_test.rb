require 'rubygems'
require 'test/unit'
require 'daemon_manager'
require 'mocha'

class DaemonManagerTest < Test::Unit::TestCase
  def test_port_are_generated_sequentially
    manager = DaemonManager.new(stub(:start))
    port1 = manager.start_new_daemon 
    port2 = manager.start_new_daemon 
    assert_equal port1, port2-1
  end

  def test_process_get_started
    starter = ProcessStarter.new
    starter.expects(:start).with(2000)
    starter.expects(:start).with(2001)

    manager = DaemonManager.new(starter)
    port1 = manager.start_new_daemon 
    port2 = manager.start_new_daemon 
  end
end

class ProcessStarterTest < Test::Unit::TestCase
  def test_start_process
    starter = ProcessStarter.new
    process = starter.start 2000
  end
end

class ProcessCollection < Test::Unit::TestCase
  def test_start_process
    manager = DaemonManager.new(stub(:start))
    manager.expects(:start_new_daemon).returns(2000)
    col = DaemonCollection.new(manager)

    empty = {}
    assert_equal empty, col.processes
    session_id = 1
    port = col.start_new_daemon session_id
    assert 2000, port

    assert_equal({session_id => 2000}, col.processes)

  end
end
