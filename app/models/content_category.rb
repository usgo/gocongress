class ContentCategory < ApplicationRecord
  include YearlyModel
  has_many :contents
  validates :name, :presence => true, :length => { maximum: 50 }

  def contents_chronological
    contents.order('created_at desc')
  end

  def contents_ordinal
    contents.order('ordinal, subject')
  end
end
