# frozen_string_literal: true

module NumberHelper
  # @return String
  def usgc_number(i)
    if i.is_a?(Integer) && (0..9).cover?(i)
      t(format('gocongress.number.%d', i))
    else
      i.to_s
    end
  end

  # @example usgc_pluralize(1, 'user') # "one user"
  # @example usgc_pluralize(2, 'user') # "two users"
  # @example usgc_pluralize(9, 'user') # "nine users"
  # @example usgc_pluralize(10, 'user') # "10 users"
  # @example usgc_pluralize(1.3, 'banana') # "1.3 bananas"
  # @return String
  def usgc_pluralize(i, singular = nil)
    int = i.is_a?(Integer)
    if singular
      noun = i != 1 || !int ? singular.pluralize(I18n.locale) : singular
      return format('%s %s', usgc_number(i), noun)
    else
      return usgc_number(i)
    end
  end
end
