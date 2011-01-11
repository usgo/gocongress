class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :crumbs

  # Redirect Devise to a specific page on successful sign in  -Jared
  def after_sign_in_path_for(resource_or_scope)
    if resource_or_scope.is_a?(User)

      # Has this user filled out the "Go Info Form" yet? -Jared
      is_go_info_form_complete = resource_or_scope.primary_attendee.congresses_attended.present?

      # If not, then go to that form, else go to the "My Account" page -Jared
      if is_go_info_form_complete
        user_path(current_user.id)
      else
        edit_attendee_path(resource_or_scope.primary_attendee.id) + "/baduk"
      end
    else
      super
    end
  end
  
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
    @deny_message += " " + controller_name
    @deny_message += " (or perhaps just this particular " + controller_name.singularize + ")."
    
    # Alf says: render or redirect and the filter chain stops there
    render 'home/access_denied', :status => :forbidden
  end

end
