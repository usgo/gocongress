class Rpt::OutstandingBalanceReportsController < Rpt::AbstractReportController
  # Pagination
  PER_PAGE = 100

  def show
    # When generating invoices for multiple users, the `includes`
    # can really speed things up.
    @users = User.yr(@year).includes([
      {
        :attendees => [
          {:attendee_activities => :activity},
          {:attendee_plans => :plan}
        ]
      }
    ]).page(params[:page]).per(PER_PAGE)
    @users_array = @users.to_a

    # Keep users with non-zero balances.  Obviously, we want to see
    # users who owe us money, but it is also useful for the registrar
    # to see people who deserve refunds.
    @users_array.delete_if { |u| (-0.01..0.01).cover?(u.balance) }

    @email_list = @users_array.map(&:email).join(', ')
  end
end
