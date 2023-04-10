# Only certain attendees show up on the "Who Is Coming" page (see
# specs for details). At first, I implemented this in ruby, using
# business logic from my models. However, it was too slow (~5s
# just to fetch ~300 attendee records) so I wrote a single SQL
# query that runs in ~8ms. I put the SQL in a separate file for
# syntax highlighting. -Jared 2013-03-21

class Attendee::WhoIsComing < ApplicationController
  DEFAULT_ORDER = 'rank = 0, rank desc'
  SORTABLE_COLUMNS = %w[given_name family_name rank state created_at country]

  attr_reader :attendees

  def initialize(year, event_type = 'in_person', sort = nil, direction = 'asc')
    super()
    @year = year
    @event_type = event_type
    @sort = sort
    @direction = direction
    @attendees = find_attendees
  end

  def count
    @attendees.count
  end

  def countries_count
    @attendees.reduce(Set[]) { |countries, attendee| countries.add(attendee.country) }.size
  end

  def pro_count
    @attendees.select { |a| a.get_rank.pro? }.length
  end

  def dan_count
    @attendees.select { |a| a.get_rank.dan? }.length
  end

  def kyu_count
    @attendees.select { |a| a.get_rank.kyu? }.length
  end

  def opposite_direction
    (@direction == 'asc') ? 'desc' : 'asc'
  end

  def unregistered_count
    Attendee.yr(@year).count - @attendees.count - Attendee.yr(@year).attendee_cancelled.count
  end

  def minor_count
    @attendees.select(&:minor?).length
  end

  def public_list
    @attendees.reject(&:minor?)
  end

  def summary_sentence
    # Construct a summary sentence with correct grammar and punctuation for a
    # list with a variable number of items.
    summary_sentence = "There #{count == 1 ? 'is' : 'are'} #{helpers.usgc_pluralize(count, '')} "
    summary_sentence += "#{count == 1 ? 'person' : 'people'} registered"
    summary_sentence += " from #{helpers.usgc_pluralize(countries_count, 'country')}"
    summary_sentence += ", including "

    summary_components = [
      kyu_count > 0 ? helpers.usgc_pluralize(kyu_count, 'kyu player') : nil,
      dan_count > 0 ? helpers.usgc_pluralize(dan_count, 'dan player') : nil,
      minor_count > 0 ? helpers.usgc_pluralize(minor_count, 'minor') + ' (not listed below)' : nil
    ]

    if pro_count > 0
      summary_components.push(helpers.usgc_pluralize(pro_count, 'pro'))
    end

    summary_sentence + summary_components.compact.to_sentence + '.'
  end

  private

  def append_direction(clause)
    clause + (%w[asc desc].include?(@direction) ? " #{@direction}" : '')
  end

  # Some sort orders could reveal clues about anonymous people, so
  # we first order by anonymity to protect against that.
  def anonymize_order(clause)
    (sort_unsafe_for_anon?(@sort) ? 'anonymous, ' : '') + clause
  end

  def attendees_qry(order_clause)
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
      event_type: @event_type,
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

  def sort_unsafe_for_anon?(sort)
    %w[given_name family_name country].include?(sort)
  end
end
