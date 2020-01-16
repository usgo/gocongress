FactoryBot.define do
  factory :tournament do
    sequence(:name) { |n| "Tournament #{n}"}
    eligible { "blah" }
    description { "blah" }
    directors { "blah" }
    openness { "O" }
    location { "" }
    year { Time.now.year }
  end
end
