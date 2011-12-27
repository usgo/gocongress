class RegistrationsController < Devise::RegistrationsController
  before_filter :remove_year_from_params, :except => [:create]
  before_filter :assert_year_matches_route

  protected

  def remove_year_from_params
    # Leaving user.year accessible and just removing it on all actions
    # except create is easier than completely re-writing 
    # Devise::RegistrationsController.create()
    if params_contains_user_attr :year
      Rails.logger.warn "WARNING: Removing protected attribute: year"
      params[:user].delete :year
    end
  end
  
  def assert_year_matches_route
    if params_contains_user_attr(:year) && params[:user][:year].to_i != @year.to_i
      raise "Invalid year in params: Expected #{@year}, found #{params[:user][:year]}"
    end
  end

  private
  
  def params_contains_user_attr(attribute)
    params.key?(:user) && params[:user].key?(attribute)
  end

end
