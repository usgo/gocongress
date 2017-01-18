require "rails_helper"

RSpec.describe NameInflector, :type => :model do
  describe "capitalize" do
    subject { NameInflector }

    it "handles all caps" do
      expect(subject.capitalize("DUDE")).to eq("Dude")
    end

    it "handles all lower case" do
      expect(subject.capitalize("dude")).to eq("Dude")
    end

    it "capitalizes all parts of a hyphenated name" do
      expect(subject.capitalize("harnett-hARgRoVE")).to eq("Harnett-Hargrove")
    end

    it "preserves the capitalization of certain English prepositions" do
      expect(subject.capitalize("MacIntyre")).to eq("MacIntyre")
      expect(subject.capitalize("Macintyre")).to eq("Macintyre")
      expect(subject.capitalize("macintyre")).to eq("Macintyre")
      expect(subject.capitalize("McIntyre")).to eq("McIntyre")
    end

    it "always capitalizes certain other English prepositions" do
      expect(subject.capitalize("O'BRIAN")).to eq("O'Brian")
      expect(subject.capitalize("o'brian")).to eq("O'Brian")
    end

    # In the future, we could implement proper capitalization of
    # other, less common international names.
    #
    # http://en.wikipedia.org/wiki/Capitalization#Compound_names
    #
    # it "preserves the capitalization of Dutch noun prepositions" do
    #   subject.capitalize("van Bruggen").should == "van Bruggen"
    #   subject.capitalize("van Tuyll van Serooskerken").should == "van Tuyll van Serooskerken"
    # end
    # it "preserves the capitalization of German noun prepositions" do
    #   subject.capitalize("von Humboldt").should == "von Humboldt"
    # end
  end
end
