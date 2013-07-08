require 'pg'

class DailyPlanCsvExporter < Exporter
  def initialize(year)
    @year = year
    @plan_names = Plan.yr(@year).daily.order(:name).all.map(&:name)
    super()
  end

  def header
    ["Attendee"] + @plan_names
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
    pg_result.group_by { |row| row["attendee_name"] }.each do |attendee_name, tuples|
      xtab_row = Array.new(header.length, nil)
      xtab_row[0] = attendee_name
      tuples.each do |t|
        xtab_col = @plan_names.index(t["plan_name"]) + 1
        xtab_row[xtab_col] = t["first_date"]
      end
      xtab << xtab_row
    end
    xtab
  end

  def matrix_to_csv(m)
    CSV.generate { |csv| m.each { |row| csv << row } }
  end

  def run_query
    qry = File.read(File.dirname(__FILE__) + '/daily_plan_export.sql')
    db.exec_params(qry, [@year.to_i])
  end
end
