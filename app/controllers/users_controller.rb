class UsersController < ApplicationController

  before_filter :deny_users_from_wrong_year, :only => [:index]
  load_and_authorize_resource :only => [:index]

  # GET /users/1/choose_attendee
  def choose_attendee
    @user = User.find(params[:id])
    authorize! :update, @user
    
    params[:destination_page] ||= "tournaments"
    is_valid_destination = %w[events tournaments].index params[:destination_page]
    raise 'Invalid destination page' unless is_valid_destination
    @destination_page = params[:destination_page]
    @destination_page_description = "sign up for " + @destination_page
  end

  # GET /users/1/edit_email
  def edit_email
    @user = User.find(params[:id])
    authorize! :update, @user
  end

  # GET /users/1/edit_password
  def edit_password
    @user = User.find(params[:id])
    authorize! :update, @user
  end

  # GET /users
  # GET /users.xml
  def index
    @users = @users.yr(@year).order("role = 'A' desc")
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])
    authorize! :show, @user
    
    @attendees = @user.attendees.order "is_primary desc"
    @showing_current_user = signed_in?(nil) && (current_user.id == @user.id)
    @page_title = @showing_current_user ?
      'My Account' :
      @user.primary_attendee.full_name_possessive + ' Account'

    @has_minor_attendee = @user.attendees.map(&:minor?).include?(true)    
    @is_deposit_paid = @user.get_num_attendee_deposits_paid == @user.attendees.count
    @is_past_deposit_due_date = @user.get_initial_deposit_due_date < Time.now.to_date
  end
  
  # GET /users/1/pay
  def pay
    @user = User.find(params[:id])
    authorize! :update, @user
    @formAction = "https://secure.merchantonegateway.com/cart/cart.php"
    if @year == 2011
      @merchantone_username = "lscott60637"
    elsif @year == 2012
      @merchantone_username = "" # FIXME: ask Peter and Paul to set up MO account
    end
  end
  
  # GET /users/1/invoice
  def invoice
    @user = User.find(params[:id])
    authorize! :read, @user
    @invoice_items = @user.get_invoice_items
  end
  
  # GET /users/1/ledger
  def ledger
    @user = User.find(params[:id])
    authorize! :read, @user
    
    @showing_current_user = signed_in?(nil) && (current_user.id == @user.id)
    @page_title = @showing_current_user ?
      'My Payment History' :
      @user.primary_attendee.full_name_possessive + ' Payment History'
  end

  # GET /users/new
  def new
    @user = User.new
    authorize! :create, @user
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
    
    # edit form is meant for admins only, hence the custom cancan action name
    authorize! :admin_edit, @user
    
    @jobs = get_jobs_for_cbx_list
  end

  # POST /users
  def create
    @user = User.new(params[:user])
    @user.year = @year
    authorize! :create, @user
    
    if @user.save
      redirect_to atnd_edit_page_path(@user.primary_attendee, :baduk)
    else
      render :action => "new"
    end
  end

  # PUT /users/1
  def update
    @user = User.find(params[:id])
    authorize! :update, @user
    
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

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    authorize! :destroy, @user
    @user.destroy
    redirect_to users_url, :notice => "User deleted"
  end
  
  def print_cost_summary
    @user = User.find(params[:id])
    authorize! :print_official_docs, @user
    render :layout => 'print'
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

end
