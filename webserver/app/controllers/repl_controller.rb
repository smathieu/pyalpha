require 'daemon_manager'
require 'daemon_proxy'

SESSION_COOKIE_ID = 'session_id'

def pretty_print_hash(hash)
  s = "{"
  hash.each_pair{ |key, value|
    s += "#{key} => #{value}, \n"
  }
  s += "}"
  s
end

class ReplController < ApplicationController
  def new_command
    error = 0
    answer = "-1"
    locals = {}

    begin
      logger.info "FULL REQUEST #{request.body.string}"
      session_id = cookies[:unique_session_id]
      logger.info "SESSION ID: #{session_id}"

      unless COLLECTION.has_session_id(session_id)
        COLLECTION.start_new_daemon(session_id)
      end

      port = COLLECTION.session_port(session_id)
      logger.info "PORT: #{port}"
      
      server_proxy = make_daemon_proxy("http://localhost:" + port.to_s)
      
      command = params[:command]
      logger.info "COMMAND: #{command}"
      logger.info "PROCESSES: #{pretty_print_hash COLLECTION.processes}"
      answer = server_proxy.eval(command)
      locals = server_proxy.get_local_vars()
      expectingMoreInput = server_proxy.expectingMoreInput()
      logger.info "Locals: #{locals}"
      logger.info "ExpectingInput: #{expectingMoreInput}"
      logger.info "ANSWER: #{answer}"
    rescue
      error = 1
    end

    raw_json = {:error => error, :answer => answer, :vars=>locals, :expectingInput=> expectingMoreInput}.to_json
    logger.info "JSON: #{raw_json}"
    raw_json = raw_json.gsub(/\\\\\\\\/, "\\\\\\")
    logger.info "JSON + excaping: #{raw_json}"

    respond_to do |format|
      #format.html
      format.json{ render :json => raw_json} 
    end
  end

  def get_response
    session_id = cookies[SESSION_COOKIE_ID]

    error = 0
    if session_id.nil?
      error = 1
      flash.now[:unauthorized]
    end
    respond_to do |format|
      format.html 
      format.json{ render :json => {:error => error}.to_json } 
    end
  end
end
