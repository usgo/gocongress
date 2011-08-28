Factory.define :tournament do |f|
  f.sequence(:name) { |n| "Tournament #{n}"}
  f.eligible "blah"
  f.description "blah"
  f.directors "blah"
  f.openness "O"
  f.year Time.now.year
  
  # Typical tournament has three to six rounds
  f.after_build do |t|
    3.upto(6) do
      t.rounds.build Factory.attributes_for(:round)
    end
  end
end
