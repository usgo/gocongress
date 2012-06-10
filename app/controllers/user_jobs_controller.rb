class UserJobsController < ApplicationController
  include YearlyController

  def index
    user_jobs_this_year = UserJob.joins(:job).where(:jobs => {:year => @year.year})
    @user_jobs = user_jobs_this_year.order(:jobname)
    @tournaments = Tournament.yr(@year).where('directors <> ?', 'TBD')
  end

end
