module AGA
  module MM
    class BuildAttendee
      def initialize(user, year, aga_id)
        raise TypeError unless user.is_a?(::User)
        raise TypeError unless year.is_a?(::Year)
        raise TypeError unless aga_id.is_a?(Integer) && aga_id > 0
        @user = user
        @year = year
        @aga_id = aga_id
      end

      def build
        attendee = Attendee.new
        attendee.user = @user
        attendee.year = @year.year

        # Get member info from the API
        api_url_prefix = "https://www.usgo.org/mm/api/members/"
        action = "#{@aga_id}?api_key=#{ENV['AGA_MEMBERS_API_KEY']}"
        url = "#{api_url_prefix}#{action}"

        begin
          buffer = URI.parse(url).open(
            read_timeout: GENERIC_READ_TIMEOUT,
            open_timeout: GENERIC_OPEN_TIMEOUT
          ).read
          result = JSON.parse(buffer)

          if result['success']
            # Pre-fill attendee values with AGA Member Info
            i = result['payload']['row']
            attendee.given_name = i['given_names']
            attendee.family_name = i['family_name']

            # Grab the first letter of gender
            # Ex: 'female' => 'f'
            attendee.gender = i['gender'][0] rescue ''

            # attendee.birth_date = i['dob']
            attendee.aga_id = i['member_id']
            # attendee.phone = i['phone']
            # attendee.email = i['email']
            # attendee.state = i['state']

            # Minimum rating is -30 (30k)
            attendee.rank = [i['rating'].to_i, -30].max.to_s

            attendee.country = country_code(i['country'])
          end
        rescue Timeout::Error, OpenURI::HTTPError => e
          # No worries! We just won't pre-fill any values.
          ::Rails.logger.error(e)
        end
        attendee
      end

      private

      def country_code(name)
        if name == 'USA'
          'US'
        else
          find_country_code_by_name(name)
        end
      end

      def find_country_code_by_name(name)
        codes = IsoCountryCodes.search_by_name(name) { nil }
        codes.first&.alpha2
      rescue IsoCountryCodes::UnknownCodeError
        nil
      end
    end
  end
end
