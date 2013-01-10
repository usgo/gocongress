class UsersController < ApplicationController
  include YearlyController

  # Callbacks, in order
  add_filter_restricting_resources_to_year_in_route
  before_filter :deny_users_from_wrong_year, :only => [:index]
  before_filter :remove_year_from_params
  load_resource
  authorize_resource :only => [:destroy, :index, :show, :update]

  # Actions
  def choose_attendee
    authorize! :update, @user

    @destination_page = params[:destination_page] || "tournaments"
    unless %w[activities events tournaments].include?(@destination_page)
      raise 'Invalid destination page'
    end

    if @user.attendees.count == 1
      redirect_to edit_attendee_path(@user.attendees.first, @destination_page)
    end

    @destination_page_description = "sign up for " + @destination_page
  end

  def edit_email
    authorize! :update, @user
  end

  def edit_password
    authorize! :update, @user
  end

  def index
    if %w[created_at last_sign_in_at].include? params[:sort]
      drn = (params[:drn] == "asc") ? :asc : :desc
      sort_order = "#{params[:sort]} #{drn}"
    else
      sort_order = "role = 'A' desc, role = 'S' desc"
    end
    @users = @users.yr(@year).order(sort_order)
  end

  def show
    @attendees = @user.attendees.order "is_primary desc"
    @has_minor_attendee = @user.attendees.map(&:minor?).include?(true)
    @start_date = CONGRESS_START_DATE[@year.year].to_formatted_s(:long)
  end

  def pay
    authorize! :update, @user
    @formAction = "https://secure.merchantonegateway.com/cart/cart.php"
    if @year.year == 2011
      @merchantone_username = "lscott60637"
    elsif @year.year == 2012
      @merchantone_username = "abridges27278"
    end
  end

  def invoice
    authorize! :show, @user
    @invoice_items = @user.invoice_items
  end

  def ledger
    authorize! :show, @user
  end

  # edit form is meant for admins only, hence the custom cancan action name
  def edit
    authorize! :admin_edit, @user
  end

  def update

    # Which view did we come from?
    params[:page] ||= 'edit'

    # Only admins can promote or demote other admins -Jared 2011.1.13
    if current_user_is_admin? && params[:user][:role].present?
      @user.role = params[:user][:role]
      @user.save
    end

    # Now that we have handled the protected attributes, remove them
    # from the params hash to avoid a warning. -Jared 2011.1.30
    mass_assignable_attrs = params[:user].except(:role)

    # Update mass-assignable attributes. update_with_password() performs
    # some extra validation before calling update_attributes
    if @user.update_with_password(mass_assignable_attrs)

      # When changing our own password, refresh session credentials
      # or else we will get logged out!
      # Credit: Bill Eisenhauer
      sign_in(@user, :bypass => true) if (current_user.id == @user.id)

      redirect_to user_path(@user), :notice => "User updated"
    else
      render :action => params[:page]
    end
  end

  def destroy
    @user.destroy
    redirect_to users_url, :notice => "User deleted"
  end

  def print_cost_summary
    authorize! :print_official_docs, @user
    render :layout => 'print'
  end

protected

  def remove_year_from_params
    # Leaving user.year accessible and just removing it on all actions
    # is easier than completely re-writing
    # Devise::RegistrationsController.create()
    if params_contains_user_attr :year
      Rails.logger.warn "WARNING: Removing protected attribute: year"
      params[:user].delete :year
    end
  end

private

  def params_contains_user_attr(attribute)
    params.key?(:user) && params[:user].key?(attribute)
  end

end
