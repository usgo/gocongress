require "rails_helper"

RSpec.describe Transaction, :type => :model do
  it_behaves_like "a yearly model"

  it "has valid factories" do
    %w[transaction tr_comp tr_refund tr_sale].each do |f|
      expect(build(f.to_sym)).to be_valid
    end
  end

  describe "#description" do
    it "includes comment, if present" do
      t = build(:tr_comp, :comment => "foobar")
      expect(t.description).to eq("Comp: foobar")
      t.comment = nil
      expect(t.description).to eq("Comp")
    end
  end

  describe "#is_gateway_transaction?" do
    it "is true for sales with card" do
      t = build(:tr_sale, :instrument => 'C')
      expect(t.is_gateway_transaction?).to be_truthy
    end

    it "is false for sales with instrument other than card" do
      t = build(:tr_sale, :instrument => 'S')
      expect(t.is_gateway_transaction?).to be_falsey
    end
  end

  describe "#valid" do
    it "validates year" do
      t = build(:tr_sale)
      expect(t).to be_valid
      [nil, 2100, 2010].each do |y|
        t.year = y
        expect(t).not_to be_valid
      end
      t.year = 2011
      expect(t).to be_valid
    end

    describe 'amount' do
      def trn_err_msg_keys amnt
        x = Transaction.new
        x.amount = amnt
        x.valid?
        x.errors.messages.keys
      end

      it 'complains when amount is a decimal' do
        expect(trn_err_msg_keys(4.2)).to include(:amount)
      end

      it 'does not complain when amount is an integer' do
        expect(trn_err_msg_keys(42)).not_to include(:amount)
      end

      it 'complains when amount is negative' do
        expect(trn_err_msg_keys(-42)).to include(:amount)
      end
    end

    context "comp" do
      it "must not have a gwtranid" do
        t = build :tr_comp, {gwtranid: 12897}
        expect(t).not_to be_valid
      end

      it "must not have a gwdate" do
        t = build :tr_comp, {gwdate: Time.now.to_date}
        expect(t).not_to be_valid
      end

      it "instrument must be blank" do
        t = build :tr_comp
        [nil, ''].each do |i|
          t.instrument = i
          expect(t).to be_valid
        end
        %w[C S K].each do |i|
          t.instrument = i
          expect(t).not_to be_valid
        end
      end

    end

    context "sale" do
      let(:txn) { build :tr_sale }

      context "gateway transaction" do
        before do
          allow(txn).to receive(:is_gateway_transaction?) { true }
        end

        it "requires gwdate" do
          txn.gwdate = nil
          expect(txn).not_to be_valid
          expect(txn.errors).to include(:gwdate)
        end

        it "requires gwtranid" do
          txn.gwtranid = nil
          expect(txn).not_to be_valid
          expect(txn.errors).to include(:gwtranid)
          expect(txn.errors[:gwtranid]).to include("can't be blank")
        end
      end
    end
  end
end
