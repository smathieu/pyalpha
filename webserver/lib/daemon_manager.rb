
class ProcessStarter
  def start(port)
    current_dir = File.dirname(__FILE__) 
    launch_script = File.join(current_dir, "../../daemon/ICServer.py start " + port.to_s)
    cmd = "python " + launch_script
    puts cmd
    f = IO.popen(cmd)
    sleep 1.0
  end
end

class DaemonManager
  def initialize(starter)
    @next_port  = 2000
    @starter = starter
  end

  def start_new_daemon
    port = @next_port
    @next_port += 1
    @starter.start port
    return port
  end
end

class DaemonCollection
  attr_reader :processes

  def initialize(manager)
    puts "INITIALIZING COLLECTION"
    @manager = manager
    @processes = {}
  end

  def start_new_daemon(session_id)
    raise Exception("Key already in Daemon collection") if @processes.has_key? session_id
    @processes[session_id] = @manager.start_new_daemon
  end

  def has_session_id(session_id)
    @processes.has_key? session_id
  end

  def session_port(session_id)
    @processes[session_id]
  end
end
