class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :crumbs
  
protected
  def crumbs
    @arCrumbs ||= Array.new
  end

  def allow_only_admin
    unless current_user && current_user.is_admin?
      @deny_message = "You do not have access to see all users"
      render 'home/access_denied', :status => :forbidden
    end
  end
end
