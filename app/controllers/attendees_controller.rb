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
      flash[:notice] = "Attendee successfully created"
      redirect_to(user_path(current_user.id))
    else
      render :action => "new"
    end
  end

  # GET /attendees/1/edit
  def edit
    @attendee = Attendee.find_by_id(params[:id].to_i)
  end

  # PUT /attendees/1
  def update
    @a = Attendee.find(params[:id])
    if @a.update_attributes(params[:attendee])
      flash[:notice] = "Attendee successfully updated"
      redirect_to(user_path(current_user.id))
    else
      render :action => "edit"
    end
  end

  # DELETE /attendees/1
  def destroy
    Attendee.find(params[:id]).destroy
    flash[:notice] = "Attendee deleted"
    
    # currently only admins can delete attendees, so it makes sense to
    # redirect to attendee#index, i think.  When non-admins can delete
    # attendees, then we have to rethink the redirect. -Jared 2011.01.07
    redirect_to attendees_path
  end

protected

  def allow_only_self_or_admin
    target_attendee = Attendee.find_by_id(params[:id].to_i)
    unless target_attendee.present? && current_user && (current_user.id.to_i == target_attendee.user_id || current_user.is_admin?)
      render_access_denied
    end
  end

end
