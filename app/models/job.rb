class Job < ActiveRecord::Base

has_many :user_jobs
has_many :users, :through => :user_jobs

validates_numericality_of :total_needed, :vacancies, :allow_nil => true

end
