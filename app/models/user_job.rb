class UserJob < ActiveRecord::Base
  attr_protected :created_at, :updated_at
  belongs_to :user
  belongs_to :job
  validates :year, :numericality => { :only_integer => true, :greater_than => 2010, :less_than => 2100 }

  before_validation do |uj|
    if uj.job.year != uj.user.year
      raise "User and Job have different years"
    end
    uj.year ||= uj.user.year
  end
end
