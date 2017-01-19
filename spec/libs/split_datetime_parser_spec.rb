require "#{Rails.root}/lib/split_datetime_parser"

class FoobarSplitDatetimeParser
  include SplitDatetimeParser
end

RSpec.describe '.parse_split_datetime' do
  it 'raises SplitDatetimeParserException when date is invalid' do
    params = {
      :airport_arrival_date => "#{Date.current.year}-01-01",
      :airport_arrival_time => "7:77 PM"
    }
    expect {
      FoobarSplitDatetimeParser.new.parse_split_datetime(params, :airport_arrival)
    }.to raise_error(SplitDatetimeParser::SplitDatetimeParserException, 'invalid date')
  end
end
