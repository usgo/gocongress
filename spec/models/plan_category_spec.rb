require "rails_helper"

RSpec.describe PlanCategory, :type => :model do
  it_behaves_like "a yearly model"

  let(:cat) { create :plan_category }
  let(:plan) { create :plan, plan_category: cat }
  let(:attendee) { create :attendee }

  before(:each) do
    plan.attendees << attendee
  end

  it "has a valid factory" do
    expect(build(:plan_category)).to be_valid
  end

  describe "#attendee_count" do
    it "returns the number of attendees in all plans" do
      expect(cat.attendee_count).to eq(1)
    end
  end

  describe "#destroy" do
    it "raises an error if an attendee has selected one of its plans" do
      expect { cat.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
    end
  end

  describe ".age_appropriate" do
    it "returns categories with at least one age appropriate plan" do
      bad_cat = create :plan_category
      create :plan, plan_category: bad_cat, age_min: 0, age_max: 12
      good_cat = create :plan_category
      create :plan, plan_category: good_cat, age_min: 13, age_max: 18
      create :plan, plan_category: good_cat, age_min: 0, age_max: 12
      good_cat_two = create :plan_category
      create :plan, plan_category: good_cat_two, age_min: 10, age_max: 13
      actual = PlanCategory.age_appropriate(13)
      expect(actual).not_to include(bad_cat)
      expect(actual).to match_array([good_cat, good_cat_two, cat])
    end
  end

  describe ".nonempty" do
    it "returns categories with at least one plan" do
      cat_with_plan = create :plan_category
      create :plan, plan_category: cat_with_plan
      empty_cat = create :plan_category
      expect(PlanCategory.nonempty).to include(cat_with_plan)
      expect(PlanCategory.nonempty).not_to include(empty_cat)
    end
  end
end
