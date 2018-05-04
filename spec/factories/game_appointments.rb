FactoryBot.define do
  factory :game_appointment do
    opponent "Gu Li"
    location "Building 6 Room 24"
    time "4:30 PM"
    time_zone "Eastern Standard"
    year Time.now.year
    attendee
    tournament
  end
end
