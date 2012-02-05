class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user_is_admin?, :page_title
  before_filter :set_yearly_vars

  def default_url_options(options={})
    { :year => @year }
  end

  def set_yearly_vars
    # In 2011 we used the constant CONGRESS_YEAR to determine the
    # current year, but going forward we will use params[:year] in most
    # places. Hopefully, when this transition is complete we will be
    # able to drop the constant.
    if params[:year].present?
      @year = params[:year].to_i
    else
      @year = CONGRESS_YEAR.to_i
    end

    # Validate year to protect against sql injection, or benign
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
      @congress_state = "North Carolina" # Peter wants the state spelled out
      @congress_date_range = "August 4 - 12"
    end

    # The layout needs a list of content and activity categories
    @content_categories_for_menu = ContentCategory.yr(@year).order(:name)
    @activity_categories_for_menu = ActivityCategory.yr(@year).order(:name)
    @tournaments_for_nav_menu = Tournament.yr(@year).nav_menu
  end

  # Redirect Devise to a specific page on successful sign in  -Jared
  def after_sign_in_path_for(resource_or_scope)
    if resource_or_scope.is_a?(User)
      user = resource_or_scope
      pa = user.primary_attendee

      # Go to the "My Account" page, unless the primary attendee
      # has not filled out the registration form yet (for example,
      # immediately after submitting the devise registration form)
      return pa.next_page(:basics)
    else
      super
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    # Rails.logger.debug exception.subject.inspect
    render_access_denied
  end

protected

  def human_action_name
    (action_name == "index") ? 'List' : action_name.titleize
  end

  # `model_class` returns the constant that refers to the model associated
  # with this controller.  If there is no associated model, return nil.
  # eg. UsersController.model_class() returns User
  # eg. ReportsController.model_class() returns nil
  def model_class
    controller_name.classify.constantize rescue nil
  end

  # `human_controller_name` is a bit of a misnomer, since it actually
  # returns the associated model name if it can, otherwise it just chops
  # off the string "Controller" from itself and returns the remainder.
  def human_controller_name
    if model_class.respond_to?(:model_name)
      model_class.model_name.human
    else
      controller_name.singularize.titleize
    end
  end

  def page_title
    case action_name
    when "index"
      return human_controller_name.pluralize.titleize
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

  def deny_users_from_wrong_year
    render_access_denied unless current_user && current_user.year == @year
  end

private

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
