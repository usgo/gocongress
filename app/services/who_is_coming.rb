# Only certain attendees show up on the "Who Is Coming" page (see
# specs for details). At first, I implemented this in ruby, using
# business logic from my models. However, it was too slow (~5s
# just to fetch ~300 attendee records) so I wrote a single SQL
# query that runs in ~8ms. I put the SQL in a separate file for
# syntax highlighting. -Jared 2013-03-21

class WhoIsComing

  def self.attendees year, order_clause = nil
    qry_params = {year: year.to_i}
    Attendee.find_by_sql [attendees_qry(order_clause), qry_params]
  end

  private

  def self.attendees_qry order_clause = nil
    q = File.read(attendees_qry_file_path)
    q += " order by " + order_clause unless order_clause.blank?
    q
  end

  def self.attendees_qry_file_path
    File.dirname(__FILE__) + '/who_is_coming.sql'
  end

end
