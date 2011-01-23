class EventsController < ApplicationController

  # Access Control
  before_filter :allow_only_admin, :except => [:index, :show]

  # GET /events
  # GET /events.xml
  def index
		@events = Event.all :order=>"evtdate asc"
		@arEventsByDate = @events.group_by {|event| event.evtdate}
  end

  # GET /events/1
  # GET /events/1.xml
  def show
    @event = Event.find(params[:id])
  end

  # GET /events/new
  # GET /events/new.xml
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
  end

  # POST /events
  # POST /events.xml
  def create
    @event = Event.new(params[:event])
    if @event.save
      redirect_to @event, :notice => 'Event was successfully created.'
    else
      render :action => "new"
    end
  end

  # PUT /events/1
  # PUT /events/1.xml
  def update
    @event = Event.find(params[:id])
    if @event.update_attributes(params[:event])
      redirect_to @event, :notice => 'Event was successfully updated.'
    else
      render :action => "edit"
    end
  end

  # DELETE /events/1
  # DELETE /events/1.xml
  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    redirect_to events_url
  end
end
