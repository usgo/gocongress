require 'spec_helper'

describe Registration::Registration do
  let(:attendee) { FactoryGirl.build :attendee }
  let(:coin_toss) { [true, false].sample }
  subject { Registration::Registration.new attendee, coin_toss }

  describe '#register_plans' do
    it 'returns something enumerable' do
      errs = subject.register_plans []
      errs.respond_to?(:each).should be_true
    end
  end
end
