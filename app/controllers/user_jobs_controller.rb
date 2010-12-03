class UserJobsController < ApplicationController

  # GET /user_jobs
  def index
    @user_jobs = UserJob.joins(:job, :user).select("jobname, email") 

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

end
