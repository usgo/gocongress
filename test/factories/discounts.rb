Factory.define :discount do |f|
  f.name "Test Discount"
  f.amount 50
  f.year Time.now.year
end

Factory.define :automatic_discount, :parent => :discount do |f|
  f.is_automatic true
end

Factory.define :nonautomatic_discount, :parent => :discount do |f|
  f.is_automatic false
end
