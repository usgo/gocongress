class CostSummariesExporter < Exporter

  HEADER = %w[user_id user_email attendee_id given_name
    family_name alternate_name plan_name price quantity]

  def initialize year
    @year = year
    super()
  end

  def attendee_plan_row tuple
    HEADER.map { |col| tuple.fetch(col) }
  end

  def qry
    db.exec_params(sql('cost_summaries'), [@year.to_i])
  end

  def to_csv
    CSV.generate do |csv|
      csv << HEADER
      qry.each do |tuple|
        csv << attendee_plan_row(tuple)
      end
    end
  end
end
