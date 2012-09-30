class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user_is_admin?, :page_title,
    :can_see_admin_menu?, :show_my_account_anchor?

  # set_year_from_params() should run first because it
  # defines @year which other methods depend on.
  before_filter :set_year_from_params
  before_filter :set_yearly_vars
  before_filter :set_display_timezone

  # When running functional tests or controller specs,
  # default_url_options() is called before callbacks, so we do not
  # depend on @year being defined yet, and we extract the year
  # directly from the params hash.
  def default_url_options options={}
    { :year => extract_year_from_params }
  end

  def set_display_timezone
    Time.zone = @year.timezone
  end

  def set_year_from_params
    @year = Year.find_by_year(extract_year_from_params)
    raise_routing_error("Year not found") unless @year.present?
  end

  def set_yearly_vars
    @congress_city = @year.city
    @congress_state = @year.state
    @congress_date_range = @year.date_range

    # The layout needs a list of content and activity categories
    @content_categories_for_menu = ContentCategory.yr(@year).order(:name)
    @activity_categories_for_menu = ActivityCategory.yr(@year).order(:name)
    @tournaments_for_nav_menu = Tournament.yr(@year).nav_menu
  end

  # Redirect Devise to a specific page after successful sign in
  def after_sign_in_path_for(resource_or_scope)
    if resource_or_scope.is_a?(User)
      resource_or_scope.after_sign_in_path
    else
      super
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    render_access_denied
  end

protected

  def human_action_name
    a = action_name.to_sym
    h = {:index => 'list', :new => 'create'}
    n = h.has_key?(a) ? h[a] : action_name
    n.titleize
  end

  # `model_class` returns the constant that refers to the model associated
  # with this controller.  If there is no associated model, return nil.
  # eg. UsersController.model_class() returns User
  # eg. ReportsController.model_class() returns nil
  def model_class
    controller_name.classify.constantize rescue nil
  end

  def require_authentication
    render_access_denied if current_user.nil?
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
      return human_action_name + ' ' + human_controller_name.titleize
    when "show"
      return human_controller_name.titleize + ' Details'
    else
      return human_controller_name.titleize + ' ' + human_action_name
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

  # `extract_year_from_params` returns an integer year, obtained either
  # from the params hash or the deprecated CONGRESS_YEAR constant.
  # If obtained from the params hash, the year is validated to protect
  # against sql injection, or benign programmer error.
  def extract_year_from_params
    year = params[:year].present? ? params[:year].to_i : CONGRESS_YEAR
    raise_routing_error("Invalid year") unless (2011..LATEST_YEAR).include?(year)
    return year
  end

  def render_access_denied
    @deny_message = Ability.explain_denial(user_signed_in?, \
      human_action_name, controller_name)
    render 'home/access_denied', :status => :forbidden
  end

  def raise_routing_error message='Not Found'
    raise ActionController::RoutingError.new message
  end

  def can_see_admin_menu?
    can?(:see_admin_menu, :layout) && current_user.year == @year.year
  end

  def show_my_account_anchor?
    current_user.present? && current_user.year == @year.year
  end

end
