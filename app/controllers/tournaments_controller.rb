class TournamentsController < ApplicationController

  load_and_authorize_resource

  # GET /tournaments
  def index
    @tournaments = @tournaments.order 'lower(name)'
    @rounds = Round.order 'round_start'
    @rounds_by_date = @rounds.group_by {|r| r.round_start.to_date}
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
    if @tournament.save
      redirect_to tournament_path(@tournament), :notice => 'Tournament was successfully created.'
    else
      render :action => "new"
    end
  end

  # PUT /tournaments/1
  def update
    if @tournament.update_attributes(params[:tournament])
      redirect_to tournament_path(@tournament), :notice => 'Tournament was successfully updated.'
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
