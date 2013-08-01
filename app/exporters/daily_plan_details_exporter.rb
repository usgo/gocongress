class DailyPlanDetailsExporter < Exporter
  def initialize year, date_range, plan_id
    @year = year.to_i
    @date_range = date_range
    @plan_id = plan_id.to_i
    super()
  end

  def crosstab(pg_result)
    xtab = []
    pg_result.group_by { |row| row["attendee_id"] }.each do |attendee_id, tuples|
      xtab_row = Array.new(header.length, false)
      xtab_row[0] = tuples[0]["family_name"]
      xtab_row[1] = tuples[0]["given_name"]
      tuples.each do |t|
        apdate = t["apdate"].to_date
        xtab_col = @date_range.find_index(apdate) + 2
        xtab_row[xtab_col] = true
      end
      xtab << xtab_row
    end
    xtab
  end

  def header
    %w[family_name given_name] + dates_for_header
  end

  def dates_for_header
    @date_range.map { |d| d.strftime('%-m/%-d') }
  end

  def run_query
    qry = File.read(File.dirname(__FILE__) + '/daily_plan_details.sql')
    db.exec_params(qry, [@year, @plan_id])
  end

  def to_matrix
    [header] + crosstab(run_query)
  end
end

