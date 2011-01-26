class TournamentsController < ApplicationController

  # Access Control
  before_filter :allow_only_admin, :except => [:index, :show]

  # GET /tournaments
  def index
    @tournaments = Tournament.order 'lower(name)'
    @rounds = Round.order 'round_start'
    @rounds_by_date = @rounds.group_by {|r| r.round_start.to_date}
  end

  # GET /tournaments/1
  def show
    @tournament = Tournament.find(params[:id])
  end

  # GET /tournaments/new
  def new
    @tournament = Tournament.new
    @tournament.rounds.build # Start with one round
  end

  # GET /tournaments/1/edit
  def edit
    @tournament = Tournament.find(params[:id])
  end

  # POST /tournaments
  def create
    @tournament = Tournament.new(params[:tournament])
    if @tournament.save
      redirect_to(@tournament, :notice => 'Tournament was successfully created.')
    else
      render :action => "new"
    end
  end

  # PUT /tournaments/1
  def update
    @tournament = Tournament.find(params[:id])
    if @tournament.update_attributes(params[:tournament])
      redirect_to(@tournament, :notice => 'Tournament was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /tournaments/1
  def destroy
    @tournament = Tournament.find(params[:id])
    @tournament.destroy
    redirect_to(tournaments_url)
  end
end
