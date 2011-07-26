class PlanCategoriesController < ApplicationController

  load_and_authorize_resource

  # GET /plan_categories
  def index
    @plan_categories = @plan_categories.order :name
  end

  # GET /plan_categories/1
  def show
  end

  # GET /plan_categories/new
  def new
  end

  # GET /plan_categories/1/edit
  def edit
  end

  # POST /plan_categories
  def create
    if @plan_category.save
      redirect_to(@plan_category, :notice => 'Plan category was successfully created.')
    else
      render :action => "new"
    end
  end

  # PUT /plan_categories/1
  def update
    if @plan_category.update_attributes(params[:plan_category])
      redirect_to(@plan_category, :notice => 'Plan category was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /plan_categories/1
  def destroy
    @plan_category.destroy
    redirect_to plan_categories_url
  end

end
