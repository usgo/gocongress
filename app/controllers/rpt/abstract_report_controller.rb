require 'csv'

class Rpt::AbstractReportController < ApplicationController
include YearlyController

# Access Control
before_filter :deny_users_from_wrong_year
before_filter :authorize_read_report
def authorize_read_report() authorize! :read, :report end

protected

def page_title
  human_controller_name
end

def render_csv(filename = nil)
  filename ||= params[:action]
  filename += '.csv'

  if request.env['HTTP_USER_AGENT'] =~ /msie/i
    headers['Pragma'] = 'public'
    headers["Content-type"] = "text/plain"
    headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
    headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
    headers['Expires'] = "0"
  else
    headers["Content-Type"] ||= 'text/csv'
    headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""
  end

  render :layout => false
end

end
