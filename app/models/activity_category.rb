class ActivityCategory < ApplicationRecord
  include YearlyModel
  has_many :activities

  validates :description, :length => { maximum: 500 }
  validates :name, :presence => true, :length => { maximum: 25 }

  def has_description?
    !description.blank?
  end
end
