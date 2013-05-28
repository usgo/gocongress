require "spec_helper"

describe NameInflector do
  describe "capitalize" do
    subject { NameInflector }

    it "handles all caps" do
      subject.capitalize("DUDE").should == "Dude"
    end

    it "handles all lower case" do
      subject.capitalize("dude").should == "Dude"
    end

    it "capitalizes all parts of a hyphenated name" do
      subject.capitalize("harnett-hARgRoVE").should == "Harnett-Hargrove"
    end

    it "preserves the capitalization of certain English prepositions" do
      subject.capitalize("MacIntyre").should == "MacIntyre"
      subject.capitalize("Macintyre").should == "Macintyre"
      subject.capitalize("macintyre").should == "Macintyre"
      subject.capitalize("McIntyre").should == "McIntyre"
    end

    it "always capitalizes certain other English prepositions" do
      subject.capitalize("O'BRIAN").should == "O'Brian"
      subject.capitalize("o'brian").should == "O'Brian"
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
