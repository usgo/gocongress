require "spec_helper"
require "controllers/rpt/shared_examples_for_reports"

describe Rpt::AttendeeReportsController do
  it_behaves_like "a report", %w[html csv]

  context "as an admin" do
    render_views

    let(:admin) { create :admin }
    before { sign_in admin }

    it "shows tshirt style name, instead of number" do
      shirt = create :shirt, :name => 'Cras vel arcu tellus, quis sodales sem'
      atnd = create :attendee, :shirt => shirt
      get :show, :format => :csv, :year => atnd.year
      response.should be_success
      ary = CSV.parse response.body
      ary.should have(2).rows
      ary[0].should_not include 'shirt_id'
      ary[0].should include 'shirt_style'
      ix = ary[0].index 'shirt_style'
      ary[1][ix].should == shirt.name
    end

    it "includes a column for each plan" do
      p1 = create :plan, :name => 'herp', :year => admin.year
      p2 = create :plan, :name => 'derp', :year => admin.year
      get :show, :format => :csv, :year => admin.year
      ary = CSV.parse response.body
      ary.should have(1).row # the header
      [p1, p2].each do |p|
        ary.first.should include "Plan: #{p.name}"
      end
    end
  end

end
