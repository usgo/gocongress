class YearsController < ApplicationController
  include YearlyController

  # Callbacks
  before_filter :deny_users_from_wrong_year
  authorize_resource
  add_filter_restricting_resources_to_year_in_route
  before_filter :expose_reg_phase_opts

  def update
    if @year.update_attributes(params[:year_record])
      redirect_to(edit_year_path, :notice => 'Settings updated')
    else
      render :action => "edit"
    end
  end

  private

  def expose_reg_phase_opts
    @reg_phase_opts = Year::REG_PHASES.each_with_index.map do |p,i|
      [(i+1).to_s + ". " + p.capitalize, p]
    end
  end

end
