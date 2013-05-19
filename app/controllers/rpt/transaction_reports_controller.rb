class Rpt::TransactionReportsController < Rpt::AbstractReportController

def show
  @transactions = Transaction.yr(@year).all

  respond_to do |format|
    format.html do
      @sales = Transaction.yr(@year).where("trantype = ?", "S")
      @comps = Transaction.yr(@year).where("trantype = ?", "C")
      @refunds = Transaction.yr(@year).where("trantype = ?", "R")

      @sales_sum = @sales.sum(:amount)
      @comps_sum = @comps.sum(:amount)
      @refunds_sum = @refunds.sum(:amount)
      @total_sum = @sales_sum - @comps_sum - @refunds_sum

      render :show
    end

    format.csv do
      csv = transactions_to_csv(@transactions)
      send_data csv, filename: csv_filename, type: 'text/csv'
    end
  end
end

  private

  def transactions_to_csv transactions
    CSV.generate do |csv|
      csv << csv_header_row
      transactions.each do |t|
        csv << transaction_to_array(t)
      end
    end
  end

  def csv_filename
    "usgc_transactions_#{Time.now.strftime("%Y-%m-%d")}.csv"
  end

  def csv_header_row
    ['Created', 'Type', 'Amount', 'User', 'Primary Attendee', 'GW Tran. ID',
      'Check No.', 'Last Edit', 'Updated', 'GW Date', 'Comment']
  end

  def transaction_to_array(t)
    a = []
    a << t.created_at.to_date
    a << t.get_trantype_name
    a << t.amount.to_f / 100
    a << t.user.email
    a << t.user.full_name
    a << t.gwtranid
    a << t.check_number
    a << (t.updated_by_user.present? ? t.updated_by_user.primary_attendee.given_name : nil)
    a << t.updated_at.to_date
    a << (t.gwdate.present? ? t.gwdate.to_date : nil)
    a << (t.comment.present? ? html_escape(t.comment) : nil)
    return a
  end
end
