class ContentCategoriesController < ApplicationController

  load_and_authorize_resource

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
    if @content_category.update_attributes(params[:content_category])
      redirect_to(@content_category, :notice => 'Category updated.')
    else
      render :action => "edit"
    end
  end
end
