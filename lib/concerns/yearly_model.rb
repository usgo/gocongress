module YearlyModel
  extend ActiveSupport::Concern

  included do
    # TODO: replace all `year` columns that reference `years.year` with
    # `year_id` columns that reference `years.id`. This is the Rails convention,
    # and it would allow this association to be named `year` instead of
    # `year_record`.
    belongs_to :year_record,
      class_name: 'Year',
      foreign_key: 'year',
      primary_key: 'year'

    validates :year,
      :numericality => { :only_integer => true, :greater_than => 2010, :less_than => 2100 },
      :presence => true
  end

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
end
