FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "factorytest#{n}@j.singlebrook.com" }
    password "whocares"
    password_confirmation "whocares"
    role 'U'
    year Time.now.year

    # When creating (saving to db) the associated resources (eg. primary
    # attendee), I think we want to create the user record first.
    # So, at this point, we should only build, but not save the association.
    association :primary_attendee, :factory => :attendee, :method => :build

    factory :admin do
      role 'A'
    end

    factory :staff do
      role 'S'
    end
  end
end
