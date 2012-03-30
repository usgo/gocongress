require "spec_helper"

describe AttendeesController do
  let(:user) { FactoryGirl.create :user }
  before do
    sign_in user
  end

  describe "#create" do
    let(:attendee) { FactoryGirl.attributes_for :attendee, :email => "test@example.com" }

    it "saves valid airport datetimes" do
      d = "#{attendee[:year]}-01-01"
      attendee[:airport_arrival_date] = d
      attendee[:airport_arrival_time] = "8:00 PM"
      expect {
        post :create, year: attendee[:year], attendee: attendee
      }.to change{ user.attendees.count }.by(1)
      arrival = Attendee.find_by_email("test@example.com").airport_arrival
      arrival.should be_present
      arrival.strftime("%Y-%m-%d %H:%M").should == "#{d} 20:00"
    end

    it "does not save invalid airport datetimes" do
      attendee[:airport_arrival_date] = "#{attendee[:year]}-01-01"
      attendee[:airport_arrival_time] = "8 PM"
      expect {
        post :create, year: attendee[:year], attendee: attendee
      }.to_not change{ user.attendees.count }
      assigns(:attendee).errors[:base].should_not be_empty
    end
  end

  describe "#update" do
    let(:attendee) { FactoryGirl.create :attendee, :user => user }

    it "updates valid airport datetimes" do
      d = "#{attendee.year}-01-01"
      put :update,
        year: attendee.year,
        id: attendee.id,
        attendee: {
          :airport_arrival_date => d,
          :airport_arrival_time => "8:00 PM"
        }
      attendee.reload
      attendee.airport_arrival.should be_present
      attendee.airport_arrival.strftime("%Y-%m-%d %H:%M").should == "#{d} 20:00"
    end

    it "does not update invalid airport datetimes" do
      put :update,
        year: attendee.year,
        id: attendee.id,
        attendee: {
          :airport_arrival_date => "1/1/#{attendee.year}",
          :airport_arrival_time => "8:00 PM"
        }
      attendee.reload
      attendee.airport_arrival.should be_nil
      assigns(:attendee).errors[:base].should_not be_empty
    end
  end
end
