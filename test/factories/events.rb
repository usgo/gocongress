FactoryGirl.define do
  factory :event do
    name             "eating lasagna"
    evtdeparttime       "round about dinner time"
    evtprice            "10"
    start               2.days.from_now
    return_depart_time  Time.now.to_time
    return_arrive_time  Time.now.to_time
    year                Time.now.year
    association         :event_category
  end
end
