class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :maybe_switch_user

  private

  def maybe_switch_user
    unless params[:user_id].blank?
      session[:user_id] = params[:user_id]
    end
  end

  def current_user_id!
    session[:user_id] || raise("Unauthorised")
  end
end
