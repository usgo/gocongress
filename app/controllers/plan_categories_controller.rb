class PlanCategoriesController < ApplicationController

  # Access Control
  before_filter :allow_only_admin

  # GET /plan_categories
  # GET /plan_categories.xml
  def index
    @plan_categories = PlanCategory.order :name

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @plan_categories }
    end
  end

  # GET /plan_categories/1
  # GET /plan_categories/1.xml
  def show
    @plan_category = PlanCategory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @plan_category }
    end
  end

  # GET /plan_categories/new
  # GET /plan_categories/new.xml
  def new
    @plan_category = PlanCategory.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @plan_category }
    end
  end

  # GET /plan_categories/1/edit
  def edit
    @plan_category = PlanCategory.find(params[:id])
  end

  # POST /plan_categories
  # POST /plan_categories.xml
  def create
    @plan_category = PlanCategory.new(params[:plan_category])

    respond_to do |format|
      if @plan_category.save
        format.html { redirect_to(@plan_category, :notice => 'Plan category was successfully created.') }
        format.xml  { render :xml => @plan_category, :status => :created, :location => @plan_category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @plan_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /plan_categories/1
  # PUT /plan_categories/1.xml
  def update
    @plan_category = PlanCategory.find(params[:id])

    respond_to do |format|
      if @plan_category.update_attributes(params[:plan_category])
        format.html { redirect_to(@plan_category, :notice => 'Plan category was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @plan_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /plan_categories/1
  # DELETE /plan_categories/1.xml
  def destroy
    @plan_category = PlanCategory.find(params[:id])
    @plan_category.destroy

    respond_to do |format|
      format.html { redirect_to(plan_categories_url) }
      format.xml  { head :ok }
    end
  end
end
