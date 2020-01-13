FactoryBot.define do

  sequence(:random_email) {|n| "test#{n}@example.com" }

  factory :user do
    email { generate(:random_email) }
    password { "whocares" }
    password_confirmation { password }
    role { 'U' }
    year { Time.now.year }

    factory :admin do
      role { 'A' }
    end

    factory :staff do
      role { 'S' }
    end
  end
end
