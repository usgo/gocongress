Factory.define :plan do |f|
  f.sequence(:name) { |n| "Factory Plan #{n}" }
  f.price rand * 1000
  f.age_min 1 + rand(100)
  f.age_max 1 + rand(100)
  f.description %w['asdf' 'fdsa'].sample
  f.has_meals true
  f.has_rooms true
end

Factory.define :all_ages_plan, :parent => :plan do |f|
  f.age_min 0
  f.age_max nil
end
