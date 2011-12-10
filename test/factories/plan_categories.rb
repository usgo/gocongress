Factory.define :plan_category do |f|
  f.sequence(:name) { |n| "Factory Plan Category #{n}" }
  f.year Time.now.year
end
