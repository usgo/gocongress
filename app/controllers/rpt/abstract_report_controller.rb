require 'csv'

class Rpt::AbstractReportController < ApplicationController
  include YearlyController

  # Access Control
  before_action :deny_users_from_wrong_year
  before_action :authorize_read_report

  def authorize_read_report() authorize! :read, :report end

  protected

  def page_title
    human_controller_name
  end
end
