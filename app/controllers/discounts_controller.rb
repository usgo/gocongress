class DiscountsController < ApplicationController
  include YearlyController

  # Callbacks, in order
  load_resource
  add_filter_to_set_resource_year
  authorize_resource
  add_filter_restricting_resources_to_year_in_route

  # GET /discounts
  def index
    @discounts = @discounts.yr(@year)
  end

  # GET /discounts/1
  def show
  end

  # GET /discounts/new
  def new
  end

  # GET /discounts/1/edit
  def edit
  end

  # POST /discounts
  def create
    @discount.year = @year.year
    if @discount.save
      redirect_to @discount, :notice => 'Discount created.'
    else
      render :action => "new"
    end
  end

  # PUT /discounts/1
  def update
    if @discount.update_attributes(params[:discount])
      redirect_to @discount, :notice => 'Discount updated.'
    else
      render :action => "edit"
    end
  end

  # DELETE /discounts/1
  def destroy
    @discount.destroy
    redirect_to discounts_url
  end

end
