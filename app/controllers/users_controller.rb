class UsersController < ApplicationController

  # Access Control
  before_filter :allow_only_admin, :except => [:show, :invoice, :pay]
  before_filter :allow_only_self_or_admin, :only => [:show, :invoice, :pay]

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
    @total_cost = @user.get_invoice_total
    @amount_paid = 0
    @balance = @total_cost - @amount_paid
    @showing_current_user = signed_in?(nil) && (current_user.id == @user.id)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end
  
  # GET /users/1/pay
  def pay
    @user = User.find(params[:id])
    @total_cost = @user.get_invoice_total
    @amount_paid = 0
    @balance = @total_cost - @amount_paid
  end
  
  # GET /users/1/invoice
  def invoice
    @user = User.find(params[:id])
    @invoice_items = @user.get_invoice_items
    @total_cost = @user.get_invoice_total
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new
    @jobs = get_job_array

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
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
    @jobs = get_job_array

    if @user.save
      redirect_to(edit_attendee_path(@user.primary_attendee.id) + "/baduk")
    else
      render :action => "new"
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
		params[:user][:job_ids] ||= []
    @user = User.find(params[:id])
    @jobs = get_job_array

    # Only admins can promote or demote other admins -Jared 2011.1.13
    if current_user_is_admin? && params[:user][:is_admin].present?
      @user.is_admin = params[:user][:is_admin]
      @user.save
    end

    # Update mass-assignable attributes -Jared 2011.1.13
    if @user.update_attributes(params[:user])
      redirect_to users_path, :notice => "User successfully updated"
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

private

	def get_job_array
		Job.all :select=>"jobs.id, jobname, 0 as has_job"
	end

end
