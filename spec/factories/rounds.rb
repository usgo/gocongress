FactoryBot.define do
  factory :round do
    tournament
    number { 1 }
    start_time { "4:30 PM" }
    year { Time.now.year }
  end
end
