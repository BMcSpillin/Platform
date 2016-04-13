class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  def current_user
    return unless session[:user_id]
    @current_user ||= User.where(session[:user_id]).first
  end
  
  protect_from_forgery with: :exception

end
