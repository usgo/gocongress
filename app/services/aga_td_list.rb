require 'open-uri'

class AgaTdList
  CACHE_KEY = 'aga_td_list'

  def self.data(ids = nil)
    member_data = parse()

    if (ids.kind_of? String)
      ids = ids.to_i
    end

    if ids.kind_of? Integer
      # A single member's data
      return member_data[ids] || {}
    elsif ids.kind_of? Array
      # Multiple members' data
      return member_data.slice(*ids)
    else
      # Everybody's data
      return member_data
    end
  end

  def self.current(id)
    current_as_of(id, Date.today)
  end

  def self.current_as_of(id, date)
    expires = data(id)[:expires]

    !(expires == nil or expires < date)
  end

  def self.refresh
    Rails.cache.delete(CACHE_KEY)
  end

  private

  def self.fetch
    # Hit the AGA TD List for data in TSV format
    file = ''
    begin
      Timeout.timeout(60) do
        file = open("https://www.usgo.org/mm/tdlista.txt") { |f| f.read }
      end
    rescue Timeout::Error
      # Fallback in case usgo.org is down.
      # Update this file as close to the beginning of Congress as possible.

      # Use a shortened version of the TD list. The full one is quite large!
      # Also, this one won't change over time, so our examples won't go out of date.
      file = open("./spec/fixtures/files/tdlista.txt") { |f| f.read }
    end

    return file
  end

  def self.parse(ids = nil)
    Rails.cache.fetch(CACHE_KEY, :expires_in => 24.hours) do
      parsed_aga_member_info = {}
      tsv = fetch()
      tsv.each_line do |line|
        values = line.split("\t")

        parsed_aga_member_info[values[1].to_i] = {
          full_name: values[0],
          membership_status: values[2],
          rating: values[3].to_f,
          expires: values[4].empty? ? nil : Date.strptime(values[4], '%m/%d/%Y'),
          club: values[5],
          state: values[6],
          sigma: values[7].to_f,
          last_rated_on: values[8].strip.empty? ? nil : Date.strptime(values[8], '%m/%d/%Y')
        }
      end

      parsed_aga_member_info
    end
  end

end
