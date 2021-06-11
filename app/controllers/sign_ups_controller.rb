class SignUpsController < Devise::RegistrationsController
  before_action :remove_year_from_params, :except => [:create]
  before_action :assert_year_matches_route
  before_action :redirect_to_year_path

  protected

  # The path used after sign up for inactive accounts. In our case, that means
  # accounts that need to confirm their email address .. which is all of them.
  # Everyone has to confirm their address. Everyone starts out "inactive".
  def after_inactive_sign_up_path_for(_resource)
    year_path
  end

  # We `remove_year_from_params` on all actions except create.
  # This allows us to leave user.year attr_accessible, which is very
  # helpful during the create action.  This implementation (deleting
  # the param) is much easier than completely re-writing
  # Devise::RegistrationsController.create()
  def remove_year_from_params
    if params_contains_user_attr :year
      Rails.logger.warn "WARNING: Removing protected attribute: year"
      params[:user].delete :year
    end
  end

  # `assert_year_matches_route` should prevent visitors from, for example,
  # using the 2012 registration form to create a 2011 user.
  def assert_year_matches_route
    if params_contains_user_attr(:year) && params[:user][:year].to_i != @year.year
      raise "Invalid year in params: Expected #{@year.year}, found #{params[:user][:year]}"
    end
  end

  def events_beside_congress
    Event.yr(@year).order(:name)
      .select{|e| !e.name.downcase.include? "congress"}
      .map(&:name)
  end
  helper_method :events_beside_congress

  def redirect_to_year_path
    if @year.year == 2019
      redirect_to year_path
    end
  end

  private

  def params_contains_user_attr(attribute)
    params.key?(:user) && params[:user].key?(attribute)
  end
end
