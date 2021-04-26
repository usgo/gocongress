FactoryBot.define do
  factory :year do
    event_type { 'in-person'}
    year { Date.current.year }
    city { 'Black Mountain' }
    date_range { 'August 4 - 12' }
    day_off_date { Date.new(2012, 8, 8) }
    ordinal_number { 28 }
    registration_phase { 'complete' }
    reply_to_email { 'derp@example.com' }
    start_date { Date.new(2012, 8, 4) }
    state { 'NC' }
    timezone { 'Eastern Time (US & Canada)' }
  end
end
