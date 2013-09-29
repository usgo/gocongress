class ContentsController < ApplicationController
  include YearlyController

  # Callbacks, in order
  load_resource
  add_filter_to_set_resource_year
  authorize_resource
  add_filter_restricting_resources_to_year_in_route

  # Actions
  def index
    @contents = @contents.yr(@year)
  end

  def create
    @content.year = @year.year
    if @content.save
      redirect_to(@content, :notice => 'Content created.')
    else
      render :action => "new"
    end
  end

  def update
    if @content.update_attributes(params[:content])
      redirect_to(@content, :notice => 'Content updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @content.destroy
    redirect_to(content_categories_url, :notice => 'Content deleted')
  end

  # Helpers
  def content_category_options
    ContentCategory.yr(@year).to_a.map {|c| [ c.name, c.id ] }
  end
  helper_method :content_category_options

end
