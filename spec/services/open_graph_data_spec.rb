# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OpenGraphData do
  describe '#description' do
    context 'with in-person event' do
      it 'includes city' do
        year = Year.new(
          event_type: 'in_person',
          year: 777,
          city: 'Xanadu',
          state: 'Yes',
          date_range: 'then to forever'
        )
        ogd = described_class.new(year)
        expect(ogd.description).to eq(
          'The 777 U.S. Go Congress will be held in Xanadu, Yes, from then to forever.'
        )
      end
    end
  end

  describe '#image' do
    it 'returns a Hash' do
      year = Year.new(year: 2021)
      ogd = described_class.new(year)
      expect(ogd.image).to eq({
        path: '2021/og-image.png',
        width: 1200,
        height: 630
      })
    end
  end

  describe '#year' do
    it 'returns integer year' do
      year = Year.new(year: 777)
      ogd = described_class.new(year)
      expect(ogd.year).to eq(777)
    end
  end
end
