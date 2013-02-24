class TournamentsController < ApplicationController
  include YearlyController

  # Callbacks, in order
  load_resource
  add_filter_to_set_resource_year
  authorize_resource
  add_filter_restricting_resources_to_year_in_route

  # Actions
  def index
    @tournaments = @tournaments.where(:year => @year.year).order('lower(name)')
  end

  def create
    @tournament.year = @year.year
    if @tournament.save
      redirect_to tournament_path(@tournament), :notice => 'Tournament created.'
    else
      render :action => "new"
    end
  end

  def update
    if @tournament.update_attributes(params[:tournament])
      redirect_to tournament_path(@tournament), :notice => 'Tournament updated.'
    else
      render :action => "edit"
    end
  end

  def destroy
    @tournament.destroy
    redirect_to tournaments_url
  end
end
