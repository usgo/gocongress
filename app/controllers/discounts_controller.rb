class DiscountsController < ApplicationController
  include YearlyController

  # Callbacks, in order
  before_filter :amount_to_cents, only: [:create, :update]
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

  private

  def amount_to_cents
    if params[:discount][:amount].present?
      params[:discount][:amount] = (params[:discount][:amount].to_f * 100).round
    end
  end

end
