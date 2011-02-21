class UsersController < ApplicationController

  # Access Control
  before_filter :allow_only_admin, :except => [:edit, :show, :invoice, :pay, :ledger, :update]
  before_filter :allow_only_self_or_admin, :only => [:edit, :show, :invoice, :pay, :ledger, :update]

  # GET /users
  # GET /users.xml
  def index
    @users = User.order("is_admin desc")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])
    @attendees = @user.attendees.order "is_primary desc"
    @showing_current_user = signed_in?(nil) && (current_user.id == @user.id)
    @page_title = @showing_current_user ?
      'My Account' :
      @user.primary_attendee.full_name_possessive + ' Account'
  end
  
  # GET /users/1/pay
  def pay
    @user = User.find(params[:id])
    @formAction = "https://secure.merchantonegateway.com/cart/cart.php"
  end
  
  # GET /users/1/invoice
  def invoice
    @user = User.find(params[:id])
    @invoice_items = @user.get_invoice_items
  end
  
  # GET /users/1/ledger
  def ledger
    @user = User.find(params[:id])
    @showing_current_user = signed_in?(nil) && (current_user.id == @user.id)
		@page_title = @showing_current_user ?
      'My Payment History' :
      @user.primary_attendee.full_name_possessive + ' Payment History'
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
    
    # Get all jobs, but also select a column "has_job" that indicates
    # whether the user we're editing has that particular job
    # Is this a railsy way to do things, or is it too much SQL?
    # -Jared 12/3/2010
  	@jobs = Job.all :order=>"jobname asc" \
  		, :joins=>"left join user_jobs on user_jobs.job_id = jobs.id and user_jobs.user_id = " + @user.id.to_s \
  		, :select=>"jobs.id, jobname, coalesce(user_jobs.user_id, 0) as has_job"
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to(edit_attendee_path(@user.primary_attendee.id) + "/baduk")
    else
      render :action => "new"
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    # Only admins can promote or demote other admins -Jared 2011.1.13
    if current_user_is_admin? && params[:user][:is_admin].present?
      @user.is_admin = params[:user][:is_admin]
      @user.save
    end

    # Only admins can assign jobs -Jared 2011.1.29
    if current_user_is_admin? && params[:user][:job_ids].present?
      @user.job_ids = params[:user][:job_ids]
      @user.save
    end

    # Now that we have handled the protected attributes, remove them
    # from the params hash to avoid a warning. -Jared 2011.1.30
    mass_assignable_attrs = params[:user].except(:is_admin, :job_ids)

    # Update mass-assignable attributes -Jared 2011.1.13
    if @user.update_attributes(mass_assignable_attrs)
      if current_user.is_admin?
        redirect_to users_path, :notice => "User successfully updated"
      else
        redirect_to user_path(@user), :notice => "User successfully updated"
      end
    else
      render :action => "edit"
    end

  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_url, :notice => "User deleted"
  end

end
