class Shirt::ShirtColorsController < ApplicationController
  include YearlyController

  # Callbacks
  load_resource :class => "Shirt::ShirtColor"
  add_filter_to_set_resource_year
  authorize_resource :class => "Shirt::ShirtColor"

  def index
    @shirt_colors = @shirt_colors.yr(@year)
  end

  def create
    @shirt_color.year = @year.year
    if @shirt_color.save
      redirect_to shirt_shirt_colors_path, :notice => 'Color added'
    else
      render :action => "new"
    end
  end

  def update
    if @shirt_color.update_attributes(params[:shirt_shirt_color])
      redirect_to shirt_shirt_colors_path, :notice => 'Color updated'
    else
      render :action => "edit"
    end
  end

  def destroy
    @shirt_color.destroy
    redirect_to(shirt_shirt_colors_path, :notice => 'Color deleted')
  end
end
