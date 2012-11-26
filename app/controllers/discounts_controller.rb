class DiscountsController < ApplicationController
  include DollarController
  include YearlyController

  # Callbacks, in order
  add_filter_converting_param_to_cents :amount
  load_resource
  add_filter_to_set_resource_year
  authorize_resource
  add_filter_restricting_resources_to_year_in_route

  # Actions
  def index
    @discounts = @discounts.yr(@year)
  end

  def create
    @discount.year = @year.year
    if @discount.save
      redirect_to @discount, :notice => 'Discount created.'
    else
      render :action => "new"
    end
  end

  def update
    if @discount.update_attributes(params[:discount])
      redirect_to @discount, :notice => 'Discount updated.'
    else
      render :action => "edit"
    end
  end

  def destroy
    @discount.destroy
    redirect_to discounts_url
  end

end
