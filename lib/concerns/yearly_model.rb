module YearlyModel
  extend ActiveSupport::Concern
  
  # The contents of included() will be run when YearlyModel is 
  # include()d in the model, thanks to ActiveSupport::Concern
  included do
    validates :year, 
      :numericality => {:only_integer => true, :greater_than => 2010, :less_than => 2100},
      :presence => true
  end

  # Methods in this "sub-module" will become class methods in whatever
  # class YearlyModel is mixed into.
  module ClassMethods
    def yr(year)
      year = year.to_i
      raise "invalid year" unless (2011..2100).include?(year)
      where(:year => year) 
    end
  end
  
  # instance methods can be added here, eg.
  # def forty_two() 42 end
  # there is no need for a "sub-module" as with ClassMethods
end
