# Only certain attendees show up on the "Who Is Coming" page (see
# specs for details). At first, I implemented this in ruby, using
# business logic from my models. However, it was too slow (~5s
# just to fetch ~300 attendee records) so I wrote a single SQL
# query that runs in ~8ms. I put the SQL in a separate file for
# syntax highlighting. -Jared 2013-03-21

class Attendee::WhoIsComing

  DEFAULT_ORDER = 'rank = 0, rank desc'
  SORTABLE_COLUMNS = %w[given_name family_name rank created_at country]

  attr_reader :attendees

  def initialize year, sort = nil, direction = 'asc'
    @year = year
    @sort = sort
    @direction = direction
    @attendees = find_attendees
  end

  def count
    @attendees.count
  end

  def pro_count
    @attendees.select{|a| a.get_rank.pro?}.count
  end

  def dan_count
    @attendees.select{|a| a.get_rank.dan?}.count
  end

  def kyu_count
    @attendees.select{|a| a.get_rank.kyu?}.count
  end

  def opposite_direction
    (@direction == 'asc') ? 'desc' : 'asc'
  end

  def unregistered_count
    Attendee.yr(@year).count - @attendees.count - Attendee.yr(@year).attendee_cancelled.count
  end

  private

  def append_direction clause
    clause + (%w[asc desc].include?(@direction) ? " #{@direction}" : '')
  end

  # Some sort orders could reveal clues about anonymous people, so
  # we first order by anonymity to protect against that.
  def anonymize_order clause
    (sort_unsafe_for_anon?(@sort) ? 'anonymous, ' : '') + clause
  end

  def attendees_qry order_clause
    q = File.read(attendees_qry_file_path)
    q += " order by " + order_clause unless order_clause.blank?
    q
  end

  def attendees_qry_file_path
    File.dirname(__FILE__) + '/who_is_coming.sql'
  end

  def find_attendees
    qry_params = {
      year: @year.to_i,
      congress_start_date: CONGRESS_START_DATE[@year.to_i]
    }
    Attendee.find_by_sql [attendees_qry(order_clause), qry_params]
  end

  # Certain fields (eg. names) are sorted case-insensitivly
  def insensitive_order
    %w[given_name family_name].include?(@sort) ? "lower(#{@sort})" : @sort
  end

  # `order_clause` validates the supplied sort field and
  # direction, and returns a sql order clause
  def order_clause
    return DEFAULT_ORDER unless SORTABLE_COLUMNS.include?(@sort)
    append_direction(anonymize_order(insensitive_order))
  end

  def sort_unsafe_for_anon? sort
    %w[given_name family_name country].include?(sort)
  end

end
