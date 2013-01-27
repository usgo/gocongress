class ContentCategory < ActiveRecord::Base
  include YearlyModel
  has_many :contents
  attr_accessible :name
  validates :name, :presence => true, :length => { maximum: 50 }

  def contents_chronological
    contents.order('created_at desc')
  end
end
