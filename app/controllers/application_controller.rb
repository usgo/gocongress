class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user_is_admin?, :page_title
  before_filter :set_year

  def default_url_options(options={})
    { :year => @year }
  end

  def set_year
    # In 2011 we used the constant CONGRESS_YEAR to determine the
    # current year, but going forward we will use params[:year] in most
    # places. Hopefully, when this transition is complete we will be
    # able to drop the constant.
    if params[:year].present?
      @year = params[:year].to_i
    else
      @year = CONGRESS_YEAR.to_i
    end
    
    # Validate year to protect against sql injection, or begign
    # programmer error.
    raise "Invalid year" unless (2011..2100).include?(@year)
    
    # Define a range of all expected years
    # Currently just used for year navigation in footer
    @years = 2011..LATEST_YEAR
    
    # Location and date also used to be constants
    # For now, an if-else is fine, but in the future, when there are
    # more years, we may want some other way to store these.
    if @year == 2011
      @congress_city = "Santa Barbara"
      @congress_state = "CA"
      @congress_date_range = "Jul 30 - Aug 7"
    elsif @year == 2012
      @congress_city = "Black Mountain"
      @congress_state = "NC"
      @congress_date_range = "August 4 - 11"
    end
  end

  # Redirect Devise to a specific page on successful sign in  -Jared
  def after_sign_in_path_for(resource_or_scope)
    if resource_or_scope.is_a?(User)
      pa = resource_or_scope.primary_attendee

      # Go to the "My Account" page, unless the primary attendee
      # has not filled out the baduk page yet (for example, immediately
      # after submitting the devise registration form)
      if pa.congresses_attended.present?
        user_path(current_user.id)
      else
        atnd_edit_page_path pa, :baduk
      end
    else
      super
    end
  end
  
  rescue_from CanCan::AccessDenied do |exception|
    # redirect_to root_url, :alert => exception.message
    render_access_denied
  end
  
protected

  def human_action_name
    (action_name == "index") ? 'List' : action_name.titleize
  end

  def human_controller_name
    controller_name.singularize.titleize
  end

  def page_title
    case action_name
    when "new", "edit"
      return human_action_name + ' ' + human_controller_name
    when "show"
      return human_controller_name + ' Details'
    else
      return human_controller_name + ' ' + human_action_name
    end
  end

  def current_user_is_admin?
    current_user.present? && current_user.is_admin?
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

  def convert_date(hash, date_symbol_or_string)
    attribute = date_symbol_or_string.to_s
    return Date.new(hash[attribute + '(1i)'].to_i, hash[attribute + '(2i)'].to_i, hash[attribute + '(3i)'].to_i)
  end

  def render_access_denied
    # A friendlier "access denied" message -Jared 2010.1.2
    @deny_message = user_signed_in? ? 'You are signed in, but' : 'You are not signed in, so of course'
    @deny_message += ' you do not have permission to '
    @deny_message += (action_name == "index") ? 'list all' : action_name
    @deny_message += ' ' + controller_name
    @deny_message += ' (or perhaps just this particular ' + controller_name.singularize + ').'
    
    # Alf says: render or redirect and the filter chain stops there
    render 'home/access_denied', :status => :forbidden
  end

end
