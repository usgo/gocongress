FactoryGirl.define do
  factory :event do
    sequence(:name) { |n| "Event #{n}" }
    year            Time.now.year
  end

  factory :plan_category do
    association     :event
    mandatory       false
    sequence(:name) { |n| "Plan Category #{n}" }
    year            Time.now.year
  end

  factory :plan do
    association     :plan_category
    sequence(:name) { |n| "Plan #{n}" }
    price           { (rand * 1000).round(2) }
    age_min         { 1 + rand(100) }
    age_max         { 1 + rand(100) }
    description     %w['asdf' 'fdsa'].sample
    max_quantity    1
    year            Time.now.year
  end

  factory :all_ages_plan, :parent => :plan do
    age_min   0
    age_max   nil
  end
end
