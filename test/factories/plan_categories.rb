Factory.define :plan_category do |f|
  f.sequence(:name) { |n| "Factory Plan Category #{n}" }
  f.show_on_prices_page false
  f.show_on_roomboard_page false
  f.show_on_reg_form false
end

Factory.define :roomboard_category, :parent => :plan_category do |f|
  f.show_on_roomboard_page true
end

Factory.define :prices_category, :parent => :plan_category do |f|
  f.show_on_prices_page true
end
