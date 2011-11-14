Factory.define :plan_category do |f|
  f.sequence(:name) { |n| "Factory Plan Category #{n}" }
  f.show_on_reg_form false
  f.year Time.now.year
end
