FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "factorytest#{n}@j.singlebrook.com" }
    password "whocares"
    password_confirmation "whocares"
    role 'U'
    year Time.now.year

    # I think we want to create the user record first, then the
    # associated resources. So, we should only build (not save)
    # the association.  Note that we must override the :is_primary
    # attribute.  Devise does not infer attributes from association
    # conditions.
    association :primary_attendee,
      :factory => :attendee,
      :strategy => :build,
      :is_primary => true

    factory :admin do
      role 'A'
    end

    factory :staff do
      role 'S'
    end
  end
end
