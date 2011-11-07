class Job < ActiveRecord::Base
  include YearlyModel

  attr_accessible :jobname, :email, :total_needed, :vacancies, :description
  
  # FIXME: in the controller, somehow year needs to get set 
  # before authorize! runs.  until then, year needs to be accessible.
  attr_accessible :year
  
  has_many :user_jobs
  has_many :users, :through => :user_jobs
  validates_numericality_of :total_needed, :vacancies, :allow_nil => true
  validates_presence_of :jobname
end
