require 'spec_helper'

describe Discount do
  describe '#valid?' do
    describe 'amount' do
      def dct_err_msg_keys amt
        d = Discount.new
        d.amount = amt
        d.valid?
        d.errors.messages.keys
      end

      it 'complains when the amount is a decimal' do
        dct_err_msg_keys(4.2).should include(:amount)
      end

      it 'does not complain when the amount is an integer' do
        dct_err_msg_keys(42).should_not include(:amount)
      end

      it 'complains when the amount is negative' do
        dct_err_msg_keys(-42).should include(:amount)
      end
    end
  end
end
