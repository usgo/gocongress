class Rpt::AttendeelessUserReportsController < Rpt::AbstractReportController

def show
  users = User.yr(@year).attendeeless.select(:email)
  @email_list = users.map(&:email).join(', ')
end

end
