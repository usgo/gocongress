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

    # `yr` is a common shortcut to limit query to current year.
    # The argument is an instance or subclass of Integer, or
    # an instance of the Year model.
    def yr(year)
      if year.is_a?(Integer)
        y = year
      elsif year.instance_of?(Year)
        y = year.year
      else
        raise ArgumentError, "Expected either Integer or Year, got #{year.class}"
      end
      where(:year => y)
    end
  end

  # instance methods can be added here, eg.
  # def forty_two() 42 end
  # there is no need for a "sub-module" as with ClassMethods
end
