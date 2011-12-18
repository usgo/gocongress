FactoryGirl.define do
  factory :plan_category do
    sequence(:name){ |n| "Factory Plan Category #{n}" }
    year Time.now.year
  end
end
