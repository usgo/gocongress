FactoryGirl.define do

  # todo: this factory is not valid because it fails to
  # specify `is_automatic`
  factory :discount do
    amount 50
    sequence(:name){|n| "Test Discount #{n}" }
    year Time.now.year
  end

  factory :automatic_discount, :parent => :discount do
    is_automatic true
  end

  factory :nonautomatic_discount, :parent => :discount do
    is_automatic false
  end

  factory :discount_for_child, :parent => :automatic_discount do
    age_min 0
    age_max 12
  end
end
