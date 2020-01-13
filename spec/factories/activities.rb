FactoryBot.define do
  factory :activity do
    name                { "eating lasagna" }
    price               { 9900 }
    leave_time          { 10.minutes.from_now }
    return_time         { 20.minutes.from_now }
    year                { Time.now.year }
    association         :activity_category
  end

  factory :activity_category do
    name   { "Activities" }
    year    { Time.now.year }
  end
end
