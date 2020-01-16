FactoryBot.define do
  factory :event do
    sequence(:name) { |n| "Event #{n}" }
    year            { Time.now.year }
  end

  factory :plan_category do
    association     :event
    mandatory       { false }
    sequence(:name) { |n| "Plan Category #{n}" }
    year            { Time.now.year }
  end

  factory :plan do
    association     :plan_category
    sequence(:name) { |n| "Plan #{n}" }
    price           { (rand * 10000).round }
    age_min         { 0 }
    age_max         { nil }
    daily           { false }
    description     { %w['asdf' 'fdsa'].sample }
    disabled        { false }
    max_quantity    { 1 }
    year            { Time.now.year }
  end

  factory :plan_which_needs_staff_approval, :parent => :plan do
    price                 { 0 }
    needs_staff_approval  { true }
  end
end
