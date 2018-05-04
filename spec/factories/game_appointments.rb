FactoryBot.define do
  factory :game_appointment do
    association :attendee_one, factory: :attendee
    association :attendee_two, factory: :attendee
    location "Building 6 Room 24"
    time "4:30 PM"
    time_zone "Eastern Standard"
    year Time.now.year
    tournament
  end
end
