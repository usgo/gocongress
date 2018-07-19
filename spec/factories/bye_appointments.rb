FactoryBot.define do
  factory :bye_appointment do
    association :attendee, factory: :attendee
    association :round, factory: :round
  end
end