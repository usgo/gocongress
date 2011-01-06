Factory.define :user do |f|
  # f is basically like User.new
  # but with some extra stuff like the sequence helper
  # .new() respects sql defaults
  f.sequence(:email) { |n| "factorytest#{n}@j.singlebrook.com" }
  f.password "whocares"
  f.password_confirmation "whocares"
  
  # We could do this ...
  # f.association :primary_attendee, :factory => :attendee
  
  # but instead we do this:
  # because we don't always want to save to the db, and the association method does that
  f.after_build do |u|
    # u represents the built user object
    u.build_primary_attendee Factory.attributes_for(:attendee)
  end
end