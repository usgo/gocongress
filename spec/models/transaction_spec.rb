require "spec_helper"

describe Transaction do
  it_behaves_like "a yearly model"

  it "has valid factories" do
    %w[transaction tr_comp tr_refund tr_sale].each do |f|
      build(f.to_sym).should be_valid
    end
  end

  describe "#description" do
    it "includes comment, if present" do
      t = build(:tr_comp, :comment => "foobar")
      t.description.should == "Comp: foobar"
      t.comment = nil
      t.description.should == "Comp"
    end
  end

  describe "#is_gateway_transaction?" do
    it "is true for sales with card" do
      t = build(:tr_sale, :instrument => 'C')
      t.is_gateway_transaction?.should be_true
    end

    it "is false for sales with instrument other than card" do
      t = build(:tr_sale, :instrument => 'S')
      t.is_gateway_transaction?.should be_false
    end
  end

  describe "#valid" do
    it "validates year" do
      t = build(:tr_sale)
      t.should be_valid
      [nil, 2100, 2010].each do |y|
        t.year = y
        t.should_not be_valid
      end
      t.year = 2011
      t.should be_valid
    end

    describe 'amount' do
      def trn_err_msg_keys amnt
        x = Transaction.new
        x.amount = amnt
        x.valid?
        x.errors.messages.keys
      end

      it 'complains when amount is a decimal' do
        trn_err_msg_keys(4.2).should include(:amount)
      end

      it 'does not complain when amount is an integer' do
        trn_err_msg_keys(42).should_not include(:amount)
      end

      it 'complains when amount is negative' do
        trn_err_msg_keys(-42).should include(:amount)
      end
    end

    context "comp" do
      it "must not have a gwtranid" do
        t = build :tr_comp, {gwtranid: 12897}
        t.should_not be_valid
      end

      it "must not have a gwdate" do
        t = build :tr_comp, {gwdate: Time.now.to_date}
        t.should_not be_valid
      end

      it "instrument must be blank" do
        t = build :tr_comp
        [nil, ''].each do |i|
          t.instrument = i
          t.should be_valid
        end
        %w[C S K].each do |i|
          t.instrument = i
          t.should_not be_valid
        end
      end

    end

    context "sale" do
      let(:txn) { build :tr_sale }

      context "gateway transaction" do
        before do
          txn.stub(:is_gateway_transaction?) { true }
        end

        it "requires gwdate" do
          txn.gwdate = nil
          txn.should_not be_valid
          txn.errors.should include(:gwdate)
        end

        it "requires gwtranid" do
          txn.gwtranid = nil
          txn.should_not be_valid
          txn.errors.should include(:gwtranid)
          txn.errors[:gwtranid].should include("can't be blank")
        end

        it "validates gwtranid numericality" do
          txn.gwtranid = "lOOOO"
          txn.should_not be_valid
          txn.errors.should include(:gwtranid)
          txn.errors[:gwtranid].should include("is not a number")
        end

        it "validates gwtranid numeric range maximum" do
          txn.gwtranid = 16404817810
          txn.should_not be_valid
          txn.errors.should include(:gwtranid)
          txn.errors[:gwtranid].should include("must be less than 2147483648")
        end
      end
    end
  end
end
