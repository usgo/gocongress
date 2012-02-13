require "spec_helper"

describe "Attendee#next_page" do
  include Rails.application.routes.url_helpers

  subject { Factory :attendee }
  let(:event) { Factory :event }
  let(:events_of_interest) { [event.id] }

  context "after finishing the basics page" do
    it "returns the path to the events page" do
      subject.next_page(:basics, nil, nil).should ==
        edit_attendee_path(subject.year, subject, :events)
    end
  end

  context "after finishing the events page" do
    context "given an age-appropriate non-empty plan category" do
      let(:plan_category) { Factory :plan_category, event: event }
      let!(:plan) { Factory :all_ages_plan, plan_category: plan_category }

      it "returns the path to the edit_plans page for the first category" do
        subject.next_page(:events, nil, events_of_interest).should ==
          edit_plans_for_attendee_path(subject.year, subject, plan_category)
      end
    end

    context "without an appropriate plan category" do
      it "returns the path to the wishes page" do
        subject.next_page(:events, nil, events_of_interest).should ==
          edit_attendee_path(subject.year, subject, :wishes)
      end
    end
  end

  context "after finishing the wishes page" do
    it "returns the path to my account" do
      subject.next_page(:wishes, nil, nil).should ==
        users_path(subject.year, subject.user)
    end
  end

  context "after finishing the edit_plans page" do
    let(:plan_category_a) { Factory :plan_category, event: event, name: "aaa" }
    let!(:plan_a1) { Factory :all_ages_plan, plan_category: plan_category_a }

    context "without an appropriate next plan category" do
      it "returns the path to the wishes page" do
        subject.next_page(nil, plan_category_a, events_of_interest).should ==
          edit_attendee_path(subject.year, subject, :wishes)
      end
    end

    context "given an appropriate next plan category" do
      let(:plan_category_b) { Factory :plan_category, event: event, name: "bbb" }
      let!(:plan_b1) { Factory :all_ages_plan, plan_category: plan_category_b }

      it "returns the path to the edit_plans page for the next category" do
        subject.next_page(nil, plan_category_a, events_of_interest).should ==
          edit_plans_for_attendee_path(subject.year, subject, plan_category_b)
      end
    end
  end

  context "after finishing the edit_tournaments page" do
    it "returns the path to my accounts" do
      subject.next_page(:tournaments, nil, nil).should ==
        users_path(subject.year, subject.user)
    end
  end
end
