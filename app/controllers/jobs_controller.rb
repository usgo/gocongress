class JobsController < ApplicationController

  # Access Control
  before_filter :allow_only_admin, :except => [:show, :index]

  # GET /jobs
  # GET /jobs.xml
  def index
    @jobs = Job.all
  end

  # GET /jobs/1
  # GET /jobs/1.xml
  def show
    @job = Job.find(params[:id])
  end

  # GET /jobs/new
  # GET /jobs/new.xml
  def new
    @job = Job.new
  end

  # GET /jobs/1/edit
  def edit
    @job = Job.find(params[:id])
  end

  # POST /jobs
  # POST /jobs.xml
  def create
    @job = Job.new(params[:job])
    if @job.save
      redirect_to @job, :notice => 'Job was successfully created.'
    else
      render 'new'
    end
  end

  # PUT /jobs/1
  # PUT /jobs/1.xml
  def update
    @job = Job.find(params[:id])
    if @job.update_attributes(params[:job])
      redirect_to @job, :notice => 'Job was successfully updated.'
    else
      render 'edit'
    end
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.xml
  def destroy
    @job = Job.find(params[:id])
    @job.destroy
    redirect_to jobs_url
  end
end
