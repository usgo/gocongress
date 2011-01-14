class UserJobsController < ApplicationController

  # Access Control
  before_filter :allow_only_admin, :except => [:index]

  # GET /user_jobs
  def index
    @user_jobs = UserJob.all
  end

end
