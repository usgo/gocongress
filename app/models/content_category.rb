class ContentCategory < ActiveRecord::Base
  include YearlyModel
  has_many :contents
  validates :name, :presence => true, :length => { maximum: 50 }
end
