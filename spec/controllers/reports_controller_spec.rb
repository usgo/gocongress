require "rails_helper"

RSpec.describe ReportsController, :type => :controller do
  let(:admin) { create :admin }
  render_views

  it 'admin can get all reports' do
    sign_in admin

    # The following reports take no paramters, and only respond to html
    %w[index invoices emails activities].each do |r|
      get r, params: { year: admin.year }
      expect(response).to be_success
    end

    # These reports take a min and max parameter
    %w[atn_reg_sheets user_invoices].each do |r|
      get r, params: { year: admin.year, min: 'a', max: 'z' }
      expect(response).to be_success
    end
  end

  describe '#atn_reg_sheets' do
    it "assigns certain ivars" do
      a = create :attendee
      sign_in admin
      get :atn_reg_sheets, params: { year: admin.year, min: 'a', max: 'z' }
      expect(response).to be_success
      expect(assigns(:attendees)).to eq([a])
      expect(assigns(:attendee_attr_names)).not_to be_empty
    end
  end

  describe "#user_invoices" do
    it "filters users alphabeticaly by name" do

      # Sign in as an admin whose email starts
      # with Z, ie. not in the range we'll be testing below.
      admin = create :admin, email: 'zhivago@example.com'
      sign_in admin

      # Create a handful of users, one for each letter of a subset
      # of the alphabet.  Also capitalize half of the names, randomly.
      "a".upto("f") do |letter|
        name = (letter * 5)
        name = name.capitalize if (rand < 0.5)
        create :user, email: "#{name}@example.com", year: admin.year
      end

      # Get the report, and expect the users to be filtered.
      get :user_invoices, params: { year: admin.year, min: "a", max: "c" }
      expect(assigns(:users).size).to eq(3)
    end
  end
end
