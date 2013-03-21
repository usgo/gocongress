# Only certain attendees show up on the "Who Is Coming" page (see
# specs for details). At first, I implemented this in ruby, using
# business logic from my models. However, it was too slow (~5s
# just to fetch ~300 attendee records) so I wrote a single SQL
# query that runs in ~8ms. I put the SQL in a separate file for
# syntax highlighting. -Jared 2013-03-21

class WhoIsComing

  def self.attendees year
    qry_params = {deposit: deposit_per_attendee, year: year}
    Attendee.find_by_sql [attendees_qry, qry_params]
  end

  def self.deposit_per_attendee
    10000 # 100 dollars, in cents
  end

  private

  def self.attendees_qry
    File.read attendees_qry_file_path
  end

  def self.attendees_qry_file_path
    File.dirname(__FILE__) + '/who_is_coming.sql'
  end

end
