require "spec_helper"

describe Transaction do
  it "has valid factories" do
    %w[transaction tr_comp tr_refund tr_sale].each do |f|
      FactoryGirl.build(f.to_sym).should be_valid
    end
  end

  describe "#is_gateway_transaction?" do
    it "is true for sales with card" do
      t = FactoryGirl.build(:tr_sale, :instrument => 'C')
      t.is_gateway_transaction?.should be_true
    end

    it "is false for sales with instrument other than card" do
      t = FactoryGirl.build(:tr_sale, :instrument => 'S')
      t.is_gateway_transaction?.should be_false
    end
  end

  describe "#valid" do

    it "requires positive sales amount" do
      t = FactoryGirl.build :tr_sale, :amount => -34
      t.should_not be_valid
    end

    it "validates year" do
      t = FactoryGirl.build(:tr_sale)
      t.should be_valid
      [nil, 2100, 2010].each do |y|
        t.year = y
        t.should_not be_valid
      end
      t.year = 2011
      t.should be_valid
    end

    context "gateway transaction" do
      let(:txn) { FactoryGirl.create :tr_sale }
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

  # The `yr` method is defined in YearlyModel, but it's convenient
  # to test it on an actual persisted model
  describe "#yr" do
    it "returns transactions from that year" do
      Transaction.should respond_to :yr
      [2011, 2012].each do |y|
        (rand(4)+1).times { FactoryGirl.create(:tr_sale, :year => y) }
        Transaction.yr(y).should =~ Transaction.where(year: y)
      end
    end
  end
end
