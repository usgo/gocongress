# frozen_string_literal: true

require 'rails_helper'

module Pandanet
  RSpec.describe Stats do
    describe '.parse' do
      it 'parses the response received from the telnet `stats` command' do
        response = <<~EOS
          Player:      cloudbrows
          Game:        go (1)
          Language:    default
          Rating:      1d    0
          Rated Games:      0
          Rank:  1d  29
          Wins:         0
          Losses:       0
          Last Access(GMT):   (Not on)    Sat May 29 13:56:48 2021
          Last Access(local): (Not on)    Sat May 29 22:56:48 2021
          Address:  panda@.us
          Country:  USA
          Community:  -
          Reg date: Mon Jan  1 00:00:00 1900
          Info:  <None>
          Defaults (help defs):  time 90, size 19, byo-yomi time 10, byo-yomi stones 25
        EOS
        stats = described_class.parse('cloudbrows', response).to_h
        expect(stats[:username]).to eq('cloudbrows')
        expect(stats[:rating]).to eq('1d')
        expect(stats[:rank]).to eq('1d')
        expect(stats[:country]).to eq('USA')
      end
    end
  end
end
