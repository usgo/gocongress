class Job < ActiveRecord::Base
  attr_accessible :jobname, :email, :total_needed, :vacancies, :description
  attr_protected :created_at, :updated_at
  has_many :user_jobs
  has_many :users, :through => :user_jobs
  validates_numericality_of :total_needed, :vacancies, :allow_nil => true
end
