class Contact < ActiveRecord::Base
  include YearlyModel
  attr_accessible :email, :family_name, :given_name, :list_order,
    :phone, :title, :year
  validates :email, \
    :presence => true, \
    :uniqueness => { :scope => :year, :case_sensitive => false }, \
    :format => { :with => EMAIL_REGEX }
  validates :family_name, :presence => true
  validates :given_name, :presence => true
  validates :list_order, :presence => true, :numericality => { :only_integer => true }
  validates :title, :presence => true

  def full_name
    given_name + " " + family_name
  end
end
