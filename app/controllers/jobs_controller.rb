class JobsController < ApplicationController

  load_and_authorize_resource

  # GET /jobs
  def index
    @jobs = @jobs.yr(@year.year).order :jobname
  end

  # GET /jobs/1
  def show
  end

  # GET /jobs/new
  def new
  end

  # GET /jobs/1/edit
  def edit
  end

  # POST /jobs
  def create
    @job.year = @year.year
    if @job.save
      redirect_to jobs_path, :notice => 'Job created.'
    else
      render 'new'
    end
  end

  # PUT /jobs/1
  def update
    if @job.update_attributes(params[:job])
      redirect_to jobs_path, :notice => 'Job updated.'
    else
      render 'edit'
    end
  end

  # DELETE /jobs/1
  def destroy
    @job.destroy
    redirect_to jobs_url
  end
end
