class DailyPlanCsvExporter < Exporter
  def initialize(year)
    @year = year
    @plan_names = Plan.yr(@year).daily.order(:name).all.map(&:name)
    super()
  end

  def header
    ["Family Name", "Given Name"] + @plan_names
  end

  def render
    xtab = crosstab(run_query)
    matrix = [header] + xtab
    matrix_to_csv(matrix)
  end

  private

  # `crosstab` - Convert a "vertical" record set into a "crosstab".
  # Do this in ruby instead of postgres.  Tablefunc crosstab() is fast,
  # but cumbersome, and this will be fast enough.
  def crosstab(pg_result)
    xtab = []
    pg_result.group_by { |row| row["attendee_id"] }.each do |attendee_id, tuples|
      xtab_row = Array.new(header.length, nil)
      xtab_row[0] = tuples[0]["family_name"]
      xtab_row[1] = tuples[0]["given_name"]
      tuples.each do |t|
        xtab_col = plan_col_num_in_xtab(t["plan_name"])
        xtab_row[xtab_col] = format_date_range(t["first_date"]..t["last_date"])
      end
      xtab << xtab_row
    end
    xtab
  end

  def format_date_range rng
    "#{rng.begin} to #{rng.end}"
  end

  def plan_col_num_in_xtab plan_name
    @plan_names.index(plan_name) + index_of_first_plan_column_in_header
  end

  def index_of_first_plan_column_in_header
    @index_of_first_plan_column_in_header ||= header.length - @plan_names.length
  end

  def matrix_to_csv(m)
    CSV.generate { |csv| m.each { |row| csv << row } }
  end

  def run_query
    qry = File.read(File.dirname(__FILE__) + '/daily_plan_export.sql')
    db.exec_params(qry, [@year.to_i])
  end
end
