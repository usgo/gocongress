class ContentCategoriesController < ApplicationController
  include YearlyController

  # Callbacks, in order
  load_resource
  add_filter_to_set_resource_year
  authorize_resource
  add_filter_restricting_resources_to_year_in_route

  # Actions
  def create
    @content_category.year = @year.year
    if @content_category.save
      redirect_to(@content_category, :notice => 'Category created.')
    else
      render :action => "new"
    end
  end

  def destroy
    @content_category.destroy
    redirect_to content_categories_url
  end

  def index
    @content_categories = @content_categories.yr(@year)
  end

  def show
    @contents = @content_category.contents_chronological
  end

  def update
    if @content_category.update_attributes!(content_category_params)
      redirect_to(@content_category, :notice => 'Category updated.')
    else
      render :action => "edit"
    end
  end

protected

  def page_title
    action_name == "show" ? @content_category.name : super
  end

  private

  def content_category_params
    params.require(:content_category).permit(:name, :table_of_contents)
  end
end
