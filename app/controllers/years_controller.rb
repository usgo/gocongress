class YearsController < ApplicationController

  before_filter :deny_users_from_wrong_year

  authorize_resource

  def edit
  end

  def update
    if @year.update_attributes(params[:year_record])
      redirect_to(edit_year_path, :notice => 'Settings updated')
    else
      render :action => "edit"
    end
  end

end
