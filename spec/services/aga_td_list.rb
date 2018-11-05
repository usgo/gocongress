require_relative '../../app/services/aga_td_list'

RSpec.describe AgaTdList do
  describe 'AGA TD List', aga_td_list_mock: true do
    it 'returns AGA member info from TD List' do
      data = AgaTdList.data

      # Get the number of lines in the td list fixture
      file = "./spec/fixtures/files/tdlista.short.txt"
      lines = File.foreach(file).count

      expect(data).to be_a(Hash)
      expect(data.keys.length).to eq(lines)
    end

    it 'returns info for one member id' do
      data = AgaTdList.data(18202)

      expect(data[:full_name]).to eq('Eagle, Nathanael')
    end

    it 'returns info for multiple member ids' do
      data = AgaTdList.data([18202, 20388])

      expect(data[18202][:full_name]).to eq('Eagle, Nathanael')
      expect(data[20388][:full_name]).to eq('Cristal, Rexford')
    end

    it 'returns an empty hash for an AGA ID that doesn\'t exist' do
      data = AgaTdList.data(34141322144)

      expect(data).to be_a(Hash)
      expect(data.keys.length).to eq(0)
    end

    it 'returns available info when given a mix of valid and invalid IDs' do
      data = AgaTdList.data([1234122134, 18202, 2341241241232])

      expect(data.keys.length).to eq(1)
      expect(data.keys[0]).to eq(18202)
      expect(data[18202][:full_name]).to eq('Eagle, Nathanael')
    end

    it 'returns whether a member is a current AGA member' do
      # Current members
      expect(AgaTdList.current(1062)).to be true
      expect(AgaTdList.current(18202)).to be true
      expect(AgaTdList.current(1310)).to be true
      # Expired members
      expect(AgaTdList.current(11955)).to be false
      expect(AgaTdList.current(8217)).to be false
      # AGA ID doesn't exist
      expect(AgaTdList.current(11231412341231)).to be false
    end

    it 'returns whether a member will be current as of a given date' do
      date = Date.new(2018, 1, 15)

      # Life member
      expect(AgaTdList.current_as_of(1062, date)).to be true
      # Expires of January 14, 2018
      expect(AgaTdList.current_as_of(20950, date)).to be false
      # AGA ID doesn't exist
      expect(AgaTdList.current_as_of(213124123123, date)).to be false
    end
  end
end
