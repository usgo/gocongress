class Shirt < ApplicationRecord
  include YearlyModel

  has_many :attendees, dependent: :restrict_with_exception

  SIZES = [
    ["None",            "NO"],
    ["Youth Small",     "YS"],
    ["Youth Medium",    "YM"],
    ["Youth Large",     "YL"],
    ["Adult Small",     "AS"],
    ["Adult Medium",    "AM"],
    ["Adult Large",     "AL"],
    ["Adult X-Large",   "1X"],
    ["Adult XX-Large",  "2X"],
    ["Adult XXX-Large", "3X"]
  ].freeze
  SIZE_CODES = SIZES.map { |s| s[1] }.freeze

  validates :description,
    :length => { :maximum => 100 },
    :presence => true
  validates :name,
    :length => { :in => 3..40 },
    :presence => true,
    :uniqueness => { :scope => :year }
  validates :hex_triplet,
    :length => { :is => 6 },
    :presence => true,
    :uniqueness => { :scope => :year }

  def self.enabled
    where(disabled: false)
  end
end
