# frozen_string_literal: true

module Pandanet
  # Data object representing information about a Pandanet username.
  class Stats
    def initialize(username, rating, rank, country)
      @username = username
      @rating = rating
      @rank = rank
      @country = country
    end

    class << self
      # Parse the response received from the telnet `stats` command.
      def parse(username, str)
        return nil if !str.present? || str.start_with?("Cannot find player.")
        rating = str.match(/Rating:\s*([1-9][0-9]?[dk])/)[1]
        rank = str.match(/Rank:\s*([1-9][0-9]?[dk])/)[1]
        country = str.match(/Country:\s*([A-Za-z]+)/)[1]
        new(username, rating, rank, country)
      end
    end

    def to_h
      {
        username: @username,
        rating: @rating,
        rank: @rank,
        country: @country
      }
    end
  end
end
