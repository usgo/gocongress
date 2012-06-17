require "spec_helper"

describe User do

  context "when initialized" do
    it "is not yet valid" do
      User.new.should_not be_valid
    end
  end

  describe "#amount_paid" do
    it "equals the total of sales minus the total of refunds" do
      user = FactoryGirl.create :user
      sales = 1.upto(3).map{ FactoryGirl.create :tr_sale, user_id: user.id }
      refunds = 1.upto(3).map{ FactoryGirl.create :tr_refund, user_id: user.id }
      sale_total = sales.map(&:amount).reduce(:+)
      refund_total = refunds.map(&:amount).reduce(:+)
      user.amount_paid.should == sale_total - refund_total
    end
  end

  describe "attendeeless scope" do
    it "returns only users with no attendees" do
      a1 = FactoryGirl.create :attendee
      u1 = a1.user
      u2 = FactoryGirl.create :user
      u2.attendees.should be_empty
      User.attendeeless.should == [u2]
    end
  end

  describe "#balance" do
    it "equals invoice total minus amount paid" do
      u = FactoryGirl.build :user
      u.stub(:get_invoice_total) { 7 }
      u.stub(:amount_paid) { 9 }
      u.balance.should == -2
    end
  end

  it "has a valid factory" do
    FactoryGirl.build(:user).should be_valid
  end

  it "is invalid if email is invalid" do
    user = FactoryGirl.build :user, :email => "herpderp"
    user.should_not be_valid
    user.errors.should include(:email)
  end

  it "is invalid if email is not unique" do
    extant = FactoryGirl.create :user, :email => "John@example.com"
    user = FactoryGirl.build :user, {email: extant.email, year: extant.year}
    user.should_not be_valid
    user.errors.should include(:email)
  end

  # In the interest of quickly migrating testunit tests into this
  # spec, the following context reproduces the testunit setup()
  context "testunit setup" do
    before(:each) do
      attendee = FactoryGirl.create :attendee
      @user = attendee.user
    end

    describe "#get_invoice_total" do
      it "includes comp transactions" do
        @user.transactions << FactoryGirl.create(:tr_comp, :user => @user, :amount => 33)
        @user.transactions << FactoryGirl.create(:tr_comp, :user => @user, :amount => 40)
        @user.get_invoice_total.should == -73
      end

      it "equals the sum of invoice items" do
        1.upto(1+rand(3)) { |a| @user.attendees << FactoryGirl.create(:attendee, :user => @user) }
        expected_sum = 0
        @user.get_invoice_items.each { |ii| expected_sum += ii.price }
        @user.get_invoice_total.should == expected_sum
      end

      it "increases when plan with qty is added" do
        @user.attendees << FactoryGirl.create(:attendee, :user => @user)
        total_before = @user.get_invoice_total

        # add a plan with qty > 1 to attendee
        p = FactoryGirl.create :plan, :max_quantity => 10 + rand(10)
        qty = 1 + rand(p.max_quantity)
        ap = AttendeePlan.new :plan_id => p.id, :quantity => qty
        @user.attendees.first.attendee_plans << ap

        # assert that user's inv. item total increases by price * qty
        expected = (total_before + qty * p.price).to_f
        actual = @user.get_invoice_total.to_f
        actual.should be_within(0.001).of(expected)

        # change plan qty by 1, assert that invoice total changes by price
        expected = @user.get_invoice_total + p.price
        ap.quantity += 1
        @user.get_invoice_total.should be_within(0.001).of(expected)
      end

      it "increases when an activity is added" do
        e = FactoryGirl.create :activity
        expect {
          @user.attendees.first.activities << e
        }.to change{ @user.get_invoice_total }.by(e.price)
      end
    end

    it "destroying a user also destroys dependent attendees" do
      num_extra_attendees = 1 + rand(3)
      1.upto(num_extra_attendees) { |a|
        @user.attendees << FactoryGirl.create(:attendee, :user => @user)
      }

      # when we destroy the user, we expect all dependent attendees
      # to be destroyed, including the primary_attendee
      expected_difference = -1 * (num_extra_attendees + 1)
      destroyed_user_id = @user.id
      expect { @user.destroy }.to change{ Attendee.count }.by(expected_difference)

      # double check
      Attendee.where(:user_id => destroyed_user_id).count.should == 0
    end

    it "age-based discounts" do
      y = Time.now.year
      dc = FactoryGirl.create(:discount, :name => "Child", :amount => 150, :age_min => 0, :age_max => 12, :is_automatic => true, :year => y)
      dy = FactoryGirl.create(:discount, :name => "Youth", :amount => 100, :age_min => 13, :age_max => 18, :is_automatic => true, :year => y)
      congress_start = CONGRESS_START_DATE[y]

      # If 12 years old on the first day of congress, then attendee
      # should get child discount and NOT youth discount
      a = FactoryGirl.create(:minor, :birth_date => congress_start - 12.years, :user => @user, :year => y)
      a.age_in_years.should == 12
      user_has_discount?(@user, dc).should == true
      user_has_discount?(@user, dy).should == false

      # 11 year old should get child discount and NOT youth discount
      a.update_attribute :birth_date, congress_start - 11.years
      a.age_in_years.truncate.should == 11
      @user.reload
      user_has_discount?(@user, dc).should == true
      user_has_discount?(@user, dy).should == false

      # 13 year old should get YOUTH discount, not child discount
      a.update_attribute :birth_date, congress_start - 13.years
      a.age_in_years.truncate.should == 13
      @user.reload
      user_has_discount?(@user, dc).should == false
      user_has_discount?(@user, dy).should == true
    end

    def user_has_discount? (user, discount)
      user.get_invoice_items.map(&:description).include?(discount.get_invoice_item_name)
    end

  end
end
