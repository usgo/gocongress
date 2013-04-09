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
      render_csv("usgc_transactions_#{Time.now.strftime("%Y-%m-%d")}")
    end
  end
end

end
