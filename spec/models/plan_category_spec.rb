require "spec_helper"

describe PlanCategory do
  let(:cat) { FactoryGirl.create :plan_category }
  let(:plan) { FactoryGirl.create :plan, plan_category_id: cat.id }
  let(:attendee) { FactoryGirl.create :attendee }

  before(:each) do
    plan.attendees << attendee
  end

  it "has a valid factory" do
    FactoryGirl.build(:plan_category).should be_valid
  end

  describe "#attendee_count" do
    it "returnes the number of attendees in all plans" do
      cat.attendee_count.should == 1
    end
  end

  describe "#destroy" do
    it "raises an error if an attendee has selected one of its plans" do
      expect { cat.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
    end
  end

  describe ".nonempty" do
    it "returns categories with at least one plan" do
      cat_with_plan = FactoryGirl.create :plan_category
      FactoryGirl.create :plan, plan_category: cat_with_plan
      empty_cat = FactoryGirl.create :plan_category
      PlanCategory.nonempty.should include(cat_with_plan)
      PlanCategory.nonempty.should_not include(empty_cat)
    end
  end
end
