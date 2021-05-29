class Tournament < ApplicationRecord
  include YearlyModel
  has_many :rounds, dependent: :destroy

  has_many :attendee_tournaments, :dependent => :destroy
  has_many :attendees, :through => :attendee_tournaments

  has_many :game_appointments

  # Openness Types:
  # Open - All attendees can sign up
  # Invitational - Admins select certain attendees
  OPENNESS_TYPES = [['Open','O'], ['Invitational','I']]

  enum event_type: [:'in-person', :online]

  SERVERS = { 
    :kgs => {
      :name => "KGS Go Server",
      :url => "http://gokgs.com/"
    },
    :igs => {
      :name => "Pandanet IGS",
      :url => "https://pandanet-igs.com/"
    },
    :ogs => {
      :name => "Online Go Server (OGS)",
      :url => "https://online-go.com/"
    }
  }

  validates_presence_of :name, :eligible, :description, :directors, :openness
  validates_length_of :openness, :is => 1
  validates_inclusion_of :openness, :in => OPENNESS_TYPES.flatten
  validates :location, :length => {:maximum => 50}
  validates :event_type, :inclusion => {:in => event_types.keys}, :presence => true
  validates :server, :inclusion => {:in => SERVERS.keys.map(&:to_s), if: proc { |t| t.event_type == "online" }}

  # Scopes, and class methods that act like scopes
  scope :this_year, -> { where(year: "#{Time.now.year}")}
  scope :nav_menu, -> { where(:show_in_nav_menu => true) }

  def init
    # Set default values
    self.registration_sign_up ||=:false
    self.event_type ||=:'in-person'
  end

  def self.openness(o) where(:openness => o) end

  def get_openness_type_name
    openness_name = ''
    OPENNESS_TYPES.each { |t| if (t[1] == self.openness) then openness_name = t[0] end }
    if openness_name.empty? then raise "assertion failed: invalid openness type" end
    return openness_name
  end

  def server_options
    [
      Tournament::SERVERS,
      proc { |t| t[0] },
      proc { |t| t[1][:name] }
    ]
  end

  def server_name
    SERVERS[self.server.to_sym][:name]
  end

  def is_online?
    event_type == :online.to_s
  end
end
