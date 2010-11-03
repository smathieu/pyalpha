class MainPageController < ApplicationController
  def serve
    session[:session_id]
    session_id = request.session_options[:id]
    cookies[:unique_session_id] = session_id
    logger.info "Main page Session Id: #{session_id}"
    respond_to do |format|
      format.html
    end
  end
end
