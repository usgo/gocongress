FactoryGirl.define do
  factory :activity do
    name                "eating lasagna"
    depart_time         5.minutes.from_now
    price               99.0
    start               10.minutes.from_now
    return_depart_time  15.minutes.from_now
    return_arrive_time  20.minutes.from_now
    year                Time.now.year
    association         :event_category
  end
end
