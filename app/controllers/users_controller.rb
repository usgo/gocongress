class UsersController < ApplicationController

  # Access Control
  before_filter :allow_only_admin, :only => [:index,:destroy]
  before_filter :allow_only_self_or_admin, :only => [:show,:edit]

  # GET /users
  # GET /users.xml
  def index
    @users = User.where("primary_attendee_id is not null")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
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

    respond_to do |format|
      if @user.save
      	flash[:notice] = "User successfully created"
        format.html { redirect_to(:action=>'index') }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
		params[:user][:job_ids] ||= []
    @user = User.find(params[:id])
    @jobs = get_job_array
		
    respond_to do |format|
      if @user.update_attributes(params[:user])
				flash[:notice] = "User successfully updated"
        format.html { redirect_to(:action=>'index') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
	  if !current_user.try(:is_admin?)
    	deletionOccurred = false
    else
			@user = User.find(params[:id])
    	@user.destroy
    	deletionOccurred = true
    end

    respond_to do |format|
    	if deletionOccurred
				flash[:notice] = "User deleted"
			else
				flash[:alert] = "Access denied"
			end
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

  # GET /users/1/resetpasswd
  def resetpasswd
		
		# creates a new token and send it with instructions about how to reset the password
		User.find(params[:id]).send_reset_password_instructions
		
		respond_to do |format|
			flash[:notice] = "Check your email for instructions to reset your password"
			format.html { redirect_to(users_url) }
			format.xml  { head :ok }
		end
	end

private

	def get_job_array
		Job.all :select=>"jobs.id, jobname, 0 as has_job"
	end

end
