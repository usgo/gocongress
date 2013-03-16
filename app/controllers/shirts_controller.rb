class ShirtsController < ApplicationController
  include YearlyController

  # Callbacks
  load_resource
  add_filter_to_set_resource_year
  authorize_resource
  add_filter_restricting_resources_to_year_in_route

  def index
    @shirts = @shirts.yr(@year).order(:name)
  end

  def create
    @shirt.year = @year.year
    if @shirt.save
      redirect_to shirts_path, :notice => 'Shirt added'
    else
      render :action => "new"
    end
  end

  def update
    if @shirt.update_attributes(params[:shirt])
      redirect_to shirts_path, :notice => 'Shirt updated'
    else
      render :action => "edit"
    end
  end

  def destroy
    @shirt.destroy
    redirect_to(shirts_path, :notice => 'Shirt deleted')
  end
end
