FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "factorytest#{n}@j.singlebrook.com" }
    password "whocares"
    password_confirmation "whocares"
    role 'U'
    year Time.now.year

    factory :admin do
      role 'A'
    end

    factory :staff do
      role 'S'
    end
  end
end
