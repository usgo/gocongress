class DailyPlanDetailsExporter < Exporter
  def initialize year, date_range
    @year = year.to_i
    @date_range = date_range
    super()
  end

  def crosstab(pg_result)
    xtab = []
    pg_result.group_by { |row| row["attendee_plan_id"] }.each do |attendee_plan_id, tuples|
      xtab_row = Array.new(header.length, 0)
      xtab_row[0] = tuples[0]["user_id"]
      xtab_row[1] = tuples[0]["attendee_id"]
      xtab_row[2] = tuples[0]["family_name"]
      xtab_row[3] = tuples[0]["given_name"]
      xtab_row[4] = tuples[0]["alternate_name"]
      xtab_row[5] = tuples[0]["plan_name"]
      tuples.each do |t|
        apdate = t["apdate"].to_date
        xtab_col = @date_range.find_index(apdate) + 6
        xtab_row[xtab_col] = 1
      end
      xtab << xtab_row
    end
    xtab
  end

  def header
    %w[user_id attendee_id family_name given_name alternate_name plan_name] + dates_for_header
  end

  def dates_for_header
    @date_range.map { |d| d.strftime('%-m/%-d') }
  end

  def to_csv
    matrix_to_csv(to_matrix)
  end

  def run_query
    qry = File.read(File.dirname(__FILE__) + '/daily_plan_details.sql')
    db.exec_params(qry, [@year])
  end

  def to_matrix
    [header] + crosstab(run_query)
  end
end

