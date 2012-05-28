class UserJobsController < ApplicationController
  include YearlyController

  # Access Control
  before_filter :allow_only_admin, :except => [:index]

  # GET /user_jobs
  def index
    user_jobs_this_year = UserJob.joins(:job).where(:jobs => {:year => @year.year})
    @user_jobs = user_jobs_this_year.order(:jobname)
  end

end
