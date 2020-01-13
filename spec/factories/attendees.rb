FactoryBot.define do

  factory :attendee do
    birth_date { "1981-09-10" }
    country { 'JP' }
    email { "example@example.com" }
    emergency_name { 'Jenny' }
    emergency_phone { '867-5309' }
    family_name { 'Vespucci' }
    gender { 'm' }
    given_name { 'Amerigo' }
    tshirt_size { 'AL' }
    receive_sms { false }
    local_phone { "6122341234" }
    rank { 3 }
    will_play_in_us_open { false }
    year { Time.now.year }
    association :user, :factory => :user, :strategy => :build
  end

  factory :ga_attendee_one, parent: :attendee do
    receive_sms { true }
    family_name { "Smith" }
    given_name { "Jack" }
    aga_id { "12345" }
    local_phone { "+16122035280" }
  end

  factory :ga_attendee_two, parent: :attendee do
    receive_sms { true }
    aga_id { "12346" }
    local_phone { "+16122035280" }
  end

  factory :teenager, :parent => :attendee do
    birth_date { CONGRESS_START_DATE[Time.now.year] - 15.years }
    guardian_full_name { "Mother Dearest" }
    understand_minor { true }
    association :guardian, :factory => :attendee, :strategy => :build
  end

  factory :minor, :parent => :attendee do
    birth_date { CONGRESS_START_DATE[Time.now.year] - 10.years }
    guardian_full_name { "Mother Dearest" }
    understand_minor { true }
    association :guardian, :factory => :attendee, :strategy => :build
  end

  # A child is less than 12 yrs old
  factory :child, :parent => :minor do
    birth_date { CONGRESS_START_DATE[Time.now.year] - 10.years }
  end

  factory :attendee_plan do
    association :attendee, :factory => :attendee, :strategy => :build
    association :plan, :factory => :plan, :strategy => :build
  end

  factory :attendee_plan_date do
    association :attendee_plan, :factory => :attendee_plan, :strategy => :build
    _date { CONGRESS_START_DATE[Date.current.year] }
  end
end
