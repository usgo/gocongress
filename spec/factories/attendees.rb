FactoryGirl.define do
  factory :attendee do
    address_1 "askldfj"
    birth_date "1981-09-10"
    city "Nagano"
    state "Nagano"
    country 'JP'
    congresses_attended 0
    email "example@example.com"
    family_name 'Vespucci'
    gender 'm'
    given_name 'Amerigo'
    tshirt_size 'AL'
    rank 3
    year Time.now.year
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

end