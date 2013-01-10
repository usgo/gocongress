require "spec_helper"

describe Attendee::Rank do

  describe '#name' do
    def nym(r) Attendee::Rank.new(r).name end

    it 'returns a humainzed name' do
      expect { nym(110) }.to raise_error
      nym(103).should == '3 pro'
      expect { nym(100) }.to raise_error
      expect { nym(8) }.to raise_error
      nym(3).should == '3 dan'
      nym(0).should == 'Non-player'
      nym(-3).should == '3 kyu'
      nym(-30).should == '30 kyu'
      expect { nym(-31) }.to raise_error
    end
  end
end
