class ContentsController < ApplicationController

  load_and_authorize_resource

  # GET /contents
  def index
    @contents = @contents.yr(@year)
  end

  # GET /contents/1
  def show
  end

  # GET /contents/new
  def new
  end

  # GET /contents/1/edit
  def edit
  end

  # POST /contents
  def create
    @content.year = @year.year
    if @content.save
      redirect_to(@content, :notice => 'Content created.')
    else
      render :action => "new"
    end
  end

  # PUT /contents/1
  def update
    if @content.update_attributes(params[:content])
      redirect_to(@content, :notice => 'Content updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /contents/1
  def destroy
    @content.destroy
    redirect_to(content_categories_url, :notice => 'Content deleted')
  end
  
  def content_category_options
    ContentCategory.yr(@year).all.map {|c| [ c.name, c.id ] }
  end
  helper_method :content_category_options

end
