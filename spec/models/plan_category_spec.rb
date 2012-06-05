require "spec_helper"

describe PlanCategory do
  let(:cat) { FactoryGirl.create :plan_category }
  let(:plan) { FactoryGirl.create :plan, plan_category: cat }
  let(:attendee) { FactoryGirl.create :attendee }

  before(:each) do
    plan.attendees << attendee
  end

  it "has a valid factory" do
    FactoryGirl.build(:plan_category).should be_valid
  end

  describe "#attendee_count" do
    it "returns the number of attendees in all plans" do
      cat.attendee_count.should == 1
    end
  end

  describe "#destroy" do
    it "raises an error if an attendee has selected one of its plans" do
      expect { cat.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
    end
  end

  describe ".age_appropriate" do
    it "returns categories with at least one age appropriate plan" do
      bad_cat = FactoryGirl.create :plan_category
      FactoryGirl.create :plan, plan_category: bad_cat, age_min: 0, age_max: 12
      good_cat = FactoryGirl.create :plan_category
      FactoryGirl.create :plan, plan_category: good_cat, age_min: 13, age_max: 18
      FactoryGirl.create :plan, plan_category: good_cat, age_min: 0, age_max: 12
      good_cat_two = FactoryGirl.create :plan_category
      FactoryGirl.create :plan, plan_category: good_cat_two, age_min: 10, age_max: 13
      actual = PlanCategory.age_appropriate(13)
      actual.should_not include(bad_cat)
      actual.should =~ [good_cat, good_cat_two, cat]
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
