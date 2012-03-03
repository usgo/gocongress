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
    age_min         0
    age_max         nil
    description     %w['asdf' 'fdsa'].sample
    max_quantity    1
    year            Time.now.year
  end

  factory :plan_which_needs_staff_approval, :parent => :plan do
    price                 0
    needs_staff_approval  true
  end
end
