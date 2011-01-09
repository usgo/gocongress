class AttendeesController < ApplicationController

  # Access Control
  before_filter :allow_only_admin, :except => [:create, :index, :new, :edit, :update]
  before_filter :allow_only_self_or_admin, :only => [:edit, :update]
  
  def index
    # by default, sort by rank (0 is non-player)
    order_by_clause = "rank = 0, rank desc"

    # if a sort order was specified, make sure it is not a SQL injection attack
    valid_sortable_columns = %w[given_name family_name rank created_at]
    if (valid_sortable_columns.include?(params[:sort])) then
      order_by_clause = params[:sort]
    end

    # get all attendees
    @attendees = Attendee.order(order_by_clause)
  end

  # GET /attendees/new
  def new
    @attendee = Attendee.new

    # copy over certain fields from the primary_attendee -Jared
    ['phone','address_1','address_2','city','state','zip','country','phone','email'].each { |f|
      @attendee[f] = current_user.primary_attendee[f]
    }
  end
  
  # POST /attendees
  def create
    @attendee = Attendee.new(params[:attendee])
    @attendee.user_id = current_user.id
    if @attendee.save
      # After successful save, redirect to the "Edit Go Info" form
      # We are afraid if we do not, then no one will fill it out -Jared
      redirect_to(edit_attendee_path(@attendee.id) + "/baduk")
    else
      render :action => "new"
    end
  end

  # GET /attendees/1/edit/basics
  def edit
    @attendee = Attendee.find_by_id(params[:id].to_i)
    
    # there are too many attendee attributes to fit them all on one form page
    # so, I've added a param called page.  Alf, would you have done this differently?
    # Thanks, -Jared 2011.01.08
    @page = params[:page].to_s
    if @page.empty? || @page == "basics"
      render "edit"
    elsif @page == "baduk"
      render "edit_baduk_info"
    elsif @page == "roomboard"
      render "room_and_board"
    else
      raise "invalid page"
    end
  end

  # PUT /attendees/1
  def update
    @attendee = Attendee.find(params[:id])
    if @attendee.update_attributes(params[:attendee])
      flash[:notice] = "Attendee successfully updated"
      redirect_to(user_path(@attendee.user_id))
    else
      render :action => "edit"
    end
  end

  # DELETE /attendees/1
  def destroy
    target_attendee = Attendee.find(params[:id])
    belonged_to_current_user = (current_user.id == target_attendee.user_id)

    # primary attendees can never be deleted
    # will this be a problem when we implement user deletion?
    if target_attendee.is_primary then raise "primary attendees can never be deleted" end

    target_attendee.destroy
    flash[:notice] = "Attendee deleted"
    if belonged_to_current_user
      redirect_to user_path(current_user)
    else
      redirect_to attendees_path
    end
  end

protected

  def allow_only_self_or_admin
    target_attendee = Attendee.find_by_id(params[:id].to_i)
    unless target_attendee.present? && current_user && (current_user.id.to_i == target_attendee.user_id || current_user.is_admin?)
      render_access_denied
    end
  end

end
