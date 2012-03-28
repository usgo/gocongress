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

  factory :attendee_minor, :parent => :attendee do
    understand_minor true
  end

  factory :ten_year_old, :parent => :attendee do
    birth_date 10.years.ago
    understand_minor true
  end
end