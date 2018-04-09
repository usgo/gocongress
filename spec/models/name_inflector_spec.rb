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

    it 'properly capitalizes suffixes Sr., Jr., and Esq.' do
      expect(subject.capitalize("o'brian sr.")).to eq("O'Brian Sr.")
      expect(subject.capitalize("o'brian jr.")).to eq("O'Brian Jr.")
      expect(subject.capitalize("o'brian esq.")).to eq("O'Brian Esq.")
      expect(subject.capitalize("harnett-hARgRoVE jr.")).to eq("Harnett-Hargrove Jr.")
      expect(subject.capitalize("eagle, jr.")).to eq("Eagle, Jr.")
      expect(subject.capitalize("EAGLE, JR.")).to eq("Eagle, Jr.")
      expect(subject.capitalize("eagle, sr.")).to eq("Eagle, Sr.")
      expect(subject.capitalize("eagle, Sr.")).to eq("Eagle, Sr.")
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
