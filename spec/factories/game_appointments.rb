FactoryBot.define do
  factory :game_appointment do
    association :attendee_one, factory: :attendee
    association :attendee_two, factory: :attendee
    location { "Building 6 Room 24" }
    sequence(:table) { |n| "#{n}"}
    time { "4:30 PM" }
    year { Time.now.year }
    round
  end
end
