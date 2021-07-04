require 'securerandom'

FactoryBot.define do
  factory :content_category do
    name { "Category " + SecureRandom.hex(2) }
    table_of_contents { false }
    sequence(:ordinal) { |n| n }
    year { Time.now.year }
  end
end
