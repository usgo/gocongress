class YearsController < ApplicationController
  include YearlyController

  # Callbacks
  before_action :deny_users_from_wrong_year
  authorize_resource
  add_filter_restricting_resources_to_year_in_route
  before_action :expose_reg_phase_opts

  def update
    if @year.update_attributes!(year_record_params)
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

  def year_record_params
    params.require(:year_record).permit(:event_type, :city, :date_range, :day_off_date,
      :ordinal_number, :refund_policy, :registration_phase, :reply_to_email,
      :start_date, :state, :timezone, :twitter_url, :venue_name, :venue_address,
      :venue_city, :venue_state, :venue_zip, :venue_url, :venue_phone)
  end
end
