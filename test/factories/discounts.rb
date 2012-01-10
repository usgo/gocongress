FactoryGirl.define do
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
end
