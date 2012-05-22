class Rpt::AbstractReportController < ApplicationController

  # Access Control
  before_filter :authorize_read_report
  def authorize_read_report() authorize! :read, :report end

end
