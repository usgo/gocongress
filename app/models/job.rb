class Job < ActiveRecord::Base
  attr_accessible :jobname, :email, :total_needed, :vacancies, :description
  has_many :user_jobs
  has_many :users, :through => :user_jobs
  validates_numericality_of :total_needed, :vacancies, :allow_nil => true
  validates_presence_of :jobname
end
