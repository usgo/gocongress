Factory.define :tournament do |f|
  f.sequence(:name) { |n| "Tournament #{n}"}
  f.elligible "blah"
  f.description "blah"
  f.directors "blah"
  f.openness "O"
end

Factory.define :invitational_tournament, :parent => :tournament do |f|
  f.openness "I"
end
