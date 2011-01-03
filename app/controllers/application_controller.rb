class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :crumbs
  
protected
  def crumbs
    @arCrumbs ||= Array.new
  end

  def allow_only_admin
    unless current_user && current_user.is_admin?
      render_access_denied
    end
  end

  def allow_only_self_or_admin
    target_user_id = params[:id].to_i
    unless current_user && (current_user.id.to_i == target_user_id || current_user.is_admin?)
      render_access_denied
    end
  end

private

  def render_access_denied
    # A friendlier "access denied" message -Jared 2010.1.2
    @deny_message = "You do not have permission to "
    @deny_message += (action_name == "index") ? "list all" : action_name
    @deny_message += " " + controller_name + "."
    
    # Alf says: render or redirect and the filter chain stops there
    render 'home/access_denied', :status => :forbidden
  end

end
