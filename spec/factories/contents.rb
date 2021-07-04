require 'securerandom'

FactoryBot.define do
  factory :content do
    body { "Content body " + SecureRandom.hex(2) }
    content_category
    subject { "Content subject " + SecureRandom.hex(2) }
    show_on_homepage { false }
    sequence(:ordinal) { |n| n }
    year { Time.now.year }
  end
end
