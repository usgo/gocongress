require "spec_helper"

describe NameInflector do
  describe "capitalize_name" do
    subject { NameInflector }

    it "handles all caps" do
      subject.capitalize_name("DUDE").should == "Dude"
    end

    it "handles all lower case" do
      subject.capitalize_name("dude").should == "Dude"
    end

    it "capitalizes all parts of a hyphenated name" do
      subject.capitalize_name("harnett-hARgRoVE").should == "Harnett-Hargrove"
    end

    it "preserves the capitalization of certain English prepositions" do
      subject.capitalize_name("MacIntyre").should == "MacIntyre"
      subject.capitalize_name("Macintyre").should == "Macintyre"
      subject.capitalize_name("macintyre").should == "Macintyre"
      subject.capitalize_name("McIntyre").should == "McIntyre"
    end

    it "always capitalizes certain other English prepositions" do
      subject.capitalize_name("O'BRIAN").should == "O'Brian"
      subject.capitalize_name("o'brian").should == "O'Brian"
    end

    # In the future, we could implement proper capitalization of
    # other, less common international names.
    #
    # http://en.wikipedia.org/wiki/Capitalization#Compound_names
    #
    # it "preserves the capitalization of Dutch noun prepositions" do
    #   subject.capitalize_name("van Bruggen").should == "van Bruggen"
    #   subject.capitalize_name("van Tuyll van Serooskerken").should == "van Tuyll van Serooskerken"
    # end
    # it "preserves the capitalization of German noun prepositions" do
    #   subject.capitalize_name("von Humboldt").should == "von Humboldt"
    # end
  end
end
