class Content < ApplicationRecord
  include YearlyModel
  belongs_to :content_category

  validates_presence_of :subject, :body
  validates_length_of :subject, :maximum => 100
  validates_inclusion_of :show_on_homepage, :in => [true, false]
  validates_datetime :expires_at, :allow_blank => true

  # Scopes
  # -----

  scope :homepage, -> { where(show_on_homepage: true) }
  scope :newest_first, -> { order("created_at desc") }
  scope :unexpired, lambda {
    where("expires_at is null or expires_at > ?", Time.zone.now )
  }

end
