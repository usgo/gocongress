class UsersController < ApplicationController
  include YearlyController

  # Callbacks, in order
  add_filter_restricting_resources_to_year_in_route
  before_filter :deny_users_from_wrong_year, :only => [:index]
  before_filter :remove_year_from_params
  load_resource
  authorize_resource :only => [:index, :show, :update]

  def cancel_attendee
    authorize! :update, @user
    @attendee = Attendee.find(params[:attendee_id])
    @attendee.update(cancelled: true)
    @attendee.attendee_plans.destroy_all
    redirect_to(@user, :notice => 'Cancelled attendee.')
  end

  def edit_email
    authorize! :update, @user
  end

  def edit_password
    authorize! :update, @user
  end

  def new
    @user = User.new(year: @year.year)
    authorize! :new, @user
  end

  def restore_attendee
    authorize! :update, @user
    @attendee = Attendee.find(params[:attendee_id])
    redirect_to edit_registration_path(@attendee), :notice => 'Please submit this form to restore this attendee.'
  end

  def create
    @user.year = @year.year
    authorize! :create, @user
    if @user.save
      UserMailer.welcome_email(@user).deliver_later
      redirect_to users_path, :notice => 'User created'
    else
      render :new
    end
  end

  def index
    if %w[email created_at current_sign_in_at].include? params[:sort]
      drn = (params[:drn] == "asc") ? :asc : :desc
      sort_order = "#{params[:sort]} #{drn}"
    else
      sort_order = "role = 'A' desc, role = 'S' desc"
    end
    @users = @users.yr(@year).order(sort_order).includes(:attendees)
  end

  def show
    @attendees = @user.attendees.order(:created_at)
    @has_minor_attendee = @attendees.map(&:minor?).include?(true)
    @start_date = CONGRESS_START_DATE[@year.year].to_formatted_s(:long)
  end

  def pay
    authorize! :update, @user
    @form_action = new_payment_url(new_payment_url_options)
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

  def print_cost_summary
    authorize! :print_official_docs, @user
    render :layout => 'print'
  end

  def update_attendee_cancelled
    @attendee = Attendee.find(params[:attendee_id])
    if @attendee.cancelled?
      redirect_to edit_registration_path(@attendee), :notice => 'Please submit this form to restore this attendee.'
    else
      @attendee.update(cancelled: true)
      @attendee.attendee_plans.destroy_all
      redirect_to(@user, :notice => 'Cancelled attendee.')
    end
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

  def new_payment_url_options
    subdom = Rails.env.production? ? 'gocongress' : 'gocongress-dev'
    {
      :host => subdom + '.herokuapp.com',
      :protocol => 'https',
      :port => 443
    }
  end

  def params_contains_user_attr(attribute)
    params.key?(:user) && params[:user].key?(attribute)
  end

end
