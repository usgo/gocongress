class Rpt::TransactionReportsController < Rpt::AbstractReportController

def show
  @transactions = Transaction.yr(@year)

  respond_to do |format|
    format.html do
      @sales = @transactions.sales
      @comps = @transactions.comps
      @refunds = @transactions.refunds

      @sales_sum = @sales.sum(:amount)
      @comps_sum = @comps.sum(:amount)
      @refunds_sum = @refunds.sum(:amount)

      @net_income = @sales_sum - @refunds_sum
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
    ['Created', 'Type', 'Amount', 'user_id', 'User', 'GW Tran. ID',
      'Check No.', 'Last Updated By', 'Updated', 'GW Date', 'Comment']
  end

  def transaction_to_array(t)
    [
      t.created_at.to_date,
      t.get_trantype_name,
      t.amount.to_f / 100,
      t.user_id,
      t.user.email,
      t.gwtranid,
      t.check_number,
      t.updated_by_user_email,
      t.updated_at.to_date,
      (t.gwdate.present? ? t.gwdate.to_date : nil),
      (t.comment.present? ? t.comment : nil)
    ]
  end
end
