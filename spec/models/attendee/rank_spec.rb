require "spec_helper"

describe Attendee::Rank, :type => :model do

  describe '#name' do
    def nym(r) Attendee::Rank.new(r).name end

    it 'returns a humainzed name' do
      expect { nym(110) }.to raise_error
      expect(nym(103)).to eq('3 pro')
      expect { nym(100) }.to raise_error
      expect { nym(8) }.to raise_error
      expect(nym(3)).to eq('3 dan')
      expect(nym(0)).to eq('Non-player')
      expect(nym(-3)).to eq('3 kyu')
      expect(nym(-30)).to eq('30 kyu')
      expect { nym(-31) }.to raise_error
    end
  end
end
