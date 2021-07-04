# frozen_string_literal: true

# Stub requests to the AGA TD List, which is a large file we don't want to hit
# unnecessarily. Use a shortened version of the TD list. The full one is quite
# large! Also, this one won't change over time, so our examples won't go out of
# date.
RSpec.configure do |config|
  config.before(:each, aga_td_list_mock: true) do
    # TODO Just use `file_fixture` once we upgrade Rails
    # tsv = file_fixture("tdlista.short.txt").read
    tsv = ''
    IO.foreach("./spec/fixtures/files/tdlista.short.txt") do |line|
      tsv += line
    end
    stub_request(:get, "https://www.usgo.org/mm/tdlista.txt")
      .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: tsv, headers: {})
  end
end
