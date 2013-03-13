FactoryGirl.define do

  factory :attendee do
    birth_date "1981-09-10"
    country 'JP'
    email "example@example.com"
    family_name 'Vespucci'
    gender 'm'
    given_name 'Amerigo'
    tshirt_size 'AL'
    rank 3
    will_play_in_us_open false
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
    understand_minor true
    association :guardian, :factory => :attendee, :strategy => :build
  end

  # A child is less than 12 yrs old
  factory :child, :parent => :minor do
    birth_date CONGRESS_START_DATE[Time.now.year] - 10.years
  end

  factory :attendee_plan do
    association :attendee, :factory => :attendee, :strategy => :build
    association :plan, :factory => :plan, :strategy => :build
  end

  factory :attendee_plan_date do
    association :attendee_plan, :factory => :attendee_plan, :strategy => :build
    _date CONGRESS_START_DATE[Date.current.year]
  end
end
