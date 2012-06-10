class UsersController < ApplicationController
  include YearlyController

  before_filter :deny_users_from_wrong_year, :only => [:index]
  before_filter :remove_year_from_params

  load_and_authorize_resource :only => [:destroy, :index, :show, :update]

  def choose_attendee
    @user = User.find(params[:id])
    authorize! :update, @user

    @destination_page = params[:destination_page] || "tournaments"
    unless %w[activities events tournaments].include?(@destination_page)
      raise 'Invalid destination page'
    end

    @destination_page_description = "sign up for " + @destination_page
  end

  def edit_email
    @user = User.find(params[:id])
    authorize! :update, @user
  end

  def edit_password
    @user = User.find(params[:id])
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
  end

  def pay
    @user = User.find(params[:id])
    authorize! :update, @user
    @formAction = "https://secure.merchantonegateway.com/cart/cart.php"
    if @year.year == 2011
      @merchantone_username = "lscott60637"
    elsif @year.year == 2012
      @merchantone_username = "abridges27278"
    end
  end

  def invoice
    @user = User.find(params[:id])
    authorize! :show, @user
    @invoice_items = @user.get_invoice_items
  end

  def ledger
    @user = User.find(params[:id])
    authorize! :show, @user
  end

  def edit
    @user = User.find(params[:id])

    # edit form is meant for admins only, hence the custom cancan action name
    authorize! :admin_edit, @user

    @jobs = get_jobs_for_cbx_list
  end

  def update

    # Which view did we come from?
    params[:page] ||= 'edit'

    # Only admins can promote or demote other admins -Jared 2011.1.13
    if current_user_is_admin? && params[:user][:role].present?
      @user.role = params[:user][:role]
      @user.save
    end

    # Only admins can assign jobs -Jared 2011.1.29
    if current_user_is_admin? && params[:user][:job_ids].present?
      @user.job_ids = params[:user][:job_ids]
      @user.save
    end

    # Now that we have handled the protected attributes, remove them
    # from the params hash to avoid a warning. -Jared 2011.1.30
    mass_assignable_attrs = params[:user].except(:role, :job_ids)

    # Update mass-assignable attributes. update_with_password() performs
    # some extra validation before calling update_attributes
    if @user.update_with_password(mass_assignable_attrs)

      # When changing our own password, refresh session credentials
      # or else we will get logged out!
      # Credit: Bill Eisenhauer
      sign_in(@user, :bypass => true) if (current_user.id == @user.id)

      redirect_to user_path(@user), :notice => "User updated"
    else
      @jobs = get_jobs_for_cbx_list
      render :action => params[:page]
    end
  end

  def destroy
    @user.destroy
    redirect_to users_url, :notice => "User deleted"
  end

  def print_cost_summary
    @user = User.find(params[:id])
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

  def get_jobs_for_cbx_list
    # Get all jobs, but also select a column "has_job" that indicates
    # whether the user we're editing has that particular job
    # Is this a railsy way to do things, or is it too much SQL?
    # -Jared 12/3/2010
    Job.yr(@year).all :select => "jobs.id, jobname, coalesce(user_jobs.user_id, 0) as has_job" \
      , :joins => "left join user_jobs on user_jobs.job_id = jobs.id and user_jobs.user_id = " + @user.id.to_s \
      , :order => :jobname
  end

  def params_contains_user_attr(attribute)
    params.key?(:user) && params[:user].key?(attribute)
  end

end
