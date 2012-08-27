require "spec_helper"

describe Transaction do
  it "has a valid factory" do
    FactoryGirl.create(:transaction).should be_valid
  end

  describe "#valid" do
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

      it "validates gwtranid presence" do
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
