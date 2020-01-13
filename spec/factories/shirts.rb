FactoryBot.define do
  factory :shirt do
    name { 'Unicorn vs. Werewolf' }
    description { 'Nam ac tortor lorem, vel egestas lorem.' }
    disabled { false }
    hex_triplet { '000000' }
    year { Time.current.year }
  end
end
