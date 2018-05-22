require_relative '../../app/services/aga_td_list'
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.describe AgaTdList do
  #TODO Just use `file_fixture` once we upgrade Rails
  # tsv = file_fixture("tdlista.short.txt").read

  tsv = ''
  # Use a shortened version of the TD list. The full one is quite large!
  # Also, this one won't change over time, so our examples won't go out of date.
  IO.foreach("./spec/fixtures/files/tdlista.short.txt") do |line|
    tsv += line
  end

  before {
    stub_request(:get, /usgo.org/).
      with(headers: {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
      to_return(status: 200, body: tsv, headers: {})
  }

  describe 'AGA TD List' do
    it 'returns AGA member info from TD List' do
      #TODO Change to a different way of controlling caching in tests
      data = AgaTdList.data

      expect(data).to be_a(Hash)
      expect(data.keys.length).to eq(tsv.split("\n").length)
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
      # Life member
      expect(AgaTdList.current(1062)).to be true
      # Full member
      expect(AgaTdList.current(18202)).to be true
      # Expired member
      expect(AgaTdList.current(11955)).to be false
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
