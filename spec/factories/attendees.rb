FactoryGirl.define do

  factory :attendee do
    birth_date "1981-09-10"
    country 'JP'
    congresses_attended 0
    email "example@example.com"
    family_name 'Vespucci'
    gender 'm'
    given_name 'Amerigo'
    tshirt_size 'AL'
    rank 3
    year Time.now.year

    # New validation: Attendees must always have
    # a user -Jared 2012-06-02
    association :user, :factory => :user, :strategy => :build

    factory :primary_attendee do
      is_primary true
    end
  end

  factory :minor, :parent => :attendee do
    birth_date CONGRESS_START_DATE[Time.now.year] - 10.years
    guardian_full_name "Mother Dearest"
    understand_minor true
  end

  # A child is less than 12 yrs old, according to
  # the factory :discount_for_child
  factory :child, :parent => :minor do
    birth_date CONGRESS_START_DATE[Time.now.year] - 10.years
  end

  factory :attendee_plan do
    association :attendee, :factory => :attendee, :strategy => :build
    association :plan, :factory => :plan, :strategy => :build
  end
end
