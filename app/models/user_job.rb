class UserJob < ActiveRecord::Base
  attr_protected :created_at, :updated_at
  belongs_to :user
  belongs_to :job
end
