class TournamentsController < ApplicationController
  include YearlyController

  # Callbacks
  load_and_authorize_resource
  add_yearly_controller_callbacks

  # GET /tournaments
  def index
    @tournaments = @tournaments.where(:year => @year.year).order('lower(name)').all
    rounds = Round.where(:tournament_id => @tournaments).order 'round_start'
    @rounds_by_date = rounds.group_by {|r| r.round_start.to_date}
  end

  # GET /tournaments/1
  def show
    @attendees = @tournament.attendees.order('rank desc')
  end

  # GET /tournaments/new
  def new
    @tournament.rounds.build # Start with one round
  end

  # GET /tournaments/1/edit
  def edit
  end

  # POST /tournaments
  def create
    @tournament.year = @year.year
    if @tournament.save
      redirect_to tournament_path(@tournament), :notice => 'Tournament created.'
    else
      render :action => "new"
    end
  end

  # PUT /tournaments/1
  def update
    if @tournament.update_attributes(params[:tournament])
      redirect_to tournament_path(@tournament), :notice => 'Tournament updated.'
    else
      render :action => "edit"
    end
  end

  # DELETE /tournaments/1
  def destroy
    @tournament.destroy
    redirect_to tournaments_url
  end
end
