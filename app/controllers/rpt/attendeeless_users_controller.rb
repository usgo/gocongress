class Rpt::AttendeelessUsersController < Rpt::AbstractReportController

def index
  users = User.yr(@year).attendeeless.select(:email)
  @email_list = users.map(&:email).join(', ')
end

end
