FactoryGirl.define do
  factory :round do
    sequence :round_start do |d|
      d.day.from_now
    end
  end
end
