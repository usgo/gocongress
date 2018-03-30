require "rails_helper"
require "controllers/rpt/shared_examples_for_reports"

RSpec.describe Rpt::AttendeeReportsController, :type => :controller do
  it_behaves_like "a report", %w[html csv]

  context "as an admin" do
    render_views

    let(:admin) { create :admin }
    before { sign_in admin }

    it "shows tshirt style name, instead of number" do
      shirt = create :shirt, :name => 'Cras vel arcu tellus, quis sodales sem'
      atnd = create :attendee, :shirt => shirt
      get :show, format: 'csv', params: { year: atnd.year }
      expect(response).to be_success
      ary = CSV.parse response.body
      expect(ary.size).to eq(2)
      expect(ary[0]).not_to include 'shirt_id'
      expect(ary[0]).to include 'shirt_style'
      ix = ary[0].index 'shirt_style'
      expect(ary[1][ix]).to eq(shirt.name)
    end

    it "includes a column for each plan" do
      p1 = create :plan, :name => 'herp', :year => admin.year
      p2 = create :plan, :name => 'derp', :year => admin.year
      get :show, format: 'csv', params: { year: admin.year }
      ary = CSV.parse response.body
      expect(ary.size).to eq(1) # the header
      [p1, p2].each do |p|
        expect(ary.first).to include "Plan: #{p.name}"
      end
    end
  end
end
