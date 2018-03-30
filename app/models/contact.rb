class Contact < ApplicationRecord
  include YearlyModel

  validates :email,
    :format => { :with => EMAIL_REGEX },
    :length => { :maximum => 100 },
    :allow_blank => true
  validates :family_name,
    :presence => true,
    :length => { :maximum => 50 }
  validates :given_name,
    :presence => true,
    :length => { :maximum => 50 }
  validates :list_order,
    :presence => true,
    :numericality => { :only_integer => true }
  validates :title,
    :presence => true,
    :length => { :maximum => 50 }

  def full_name
    given_name + " " + family_name
  end
end
