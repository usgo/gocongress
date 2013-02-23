require "spec_helper"

describe User do
  it_behaves_like "a yearly model"

  context "when initialized" do
    it "is not yet valid" do
      User.new.should_not be_valid
    end
  end

  describe "#amount_paid" do
    it "equals the total of sales minus the total of refunds" do
      user = create :user
      sales = 1.upto(3).map{ create :tr_sale, user_id: user.id }
      refunds = 1.upto(3).map{ create :tr_refund, user_id: user.id }
      sale_total = sales.map(&:amount).reduce(:+)
      refund_total = refunds.map(&:amount).reduce(:+)
      user.amount_paid.should == sale_total - refund_total
    end
  end

  describe "attendeeless scope" do
    it "returns only users with no attendees" do
      a1 = create :attendee
      u1 = a1.user
      u2 = create :user
      u2.attendees.should be_empty
      User.attendeeless.should == [u2]
    end
  end

  describe "#balance" do
    it "equals invoice total minus amount paid" do
      u = build :user
      u.stub(:get_invoice_total) { 7 }
      u.stub(:amount_paid) { 9 }
      u.balance.should == -2
    end
  end

  describe 'email' do
    let(:capital_email) { 'Asdf@example.com' }

    it 'is downcased when saved, or used in a finder' do
      create(:user, email: capital_email)
      User.find_by_email(capital_email.downcase).should_not be_nil
      User.find_by_email(capital_email).should_not be_nil
    end
  end

  describe "#invoice_items" do
    let(:attendee) { create :attendee }
    let(:user) { attendee.user }

    it "includes invoice items from all attendees" do
      create :attendee, :user => user
      items = [:foo, :bar]
      Attendee.any_instance.stub(:invoice_items) { items }
      user.invoice_items.should =~ items * 2
    end

    it "includes comp transactions" do
      comp = create(:tr_comp, :user => user, :amount => 777)
      items = user.invoice_items
      items.should have(1).item
      items.first.price.should == comp.amount * -1
    end
  end

  it "has a valid factory" do
    build(:user).should be_valid
  end

  describe '#valid' do
    it "is invalid if email is invalid" do
      user = build :user, :email => "herpderp"
      user.should_not be_valid
      user.errors.should include(:email)
    end

    it "is invalid if email is not unique" do
      extant = create :user, :email => "John@example.com"
      user = build :user, {email: extant.email, year: extant.year}
      user.should_not be_valid
      user.errors.should include(:email)
    end
  end

  describe "#get_invoice_total" do

    it "equals the sum of invoice items" do
      user = build :user
      user.stub(:invoice_items) {[
        InvoiceItem.new("Baubles", "John", 1.5, 2),
        InvoiceItem.new("Trinkets", "Jane", -0.75, 1)
      ]}
      user.get_invoice_total.should == 2.25
    end

    it "increases when plan with qty is added" do
      attendee = create :attendee
      user = attendee.user
      total_before = user.get_invoice_total

      # add a plan with qty > 1 to attendee
      p = create :plan, :max_quantity => 10 + rand(10)
      qty = 1 + rand(p.max_quantity)
      ap = AttendeePlan.new :plan_id => p.id, :quantity => qty
      user.attendees.first.attendee_plans << ap

      # assert that user's inv. item total increases by price * qty
      expected = (total_before + qty * p.price).to_f
      actual = user.get_invoice_total.to_f
      actual.should be_within(0.001).of(expected)

      # change plan qty by 1, assert that invoice total changes by price
      expected = user.get_invoice_total + p.price
      ap.quantity += 1
      user.get_invoice_total.should be_within(0.001).of(expected)
    end

  end

  # In the interest of quickly migrating testunit tests into this
  # spec, the following context reproduces the testunit setup()
  context "testunit setup" do
    before(:each) do
      attendee = create :attendee
      @user = attendee.user
    end

    it "destroying a user also destroys dependent attendees" do
      num_extra_attendees = 1 + rand(3)
      1.upto(num_extra_attendees) { |a|
        @user.attendees << create(:attendee, :user => @user)
      }

      # when we destroy the user, we expect all dependent attendees
      # to be destroyed, including the primary_attendee
      expected_difference = -1 * (num_extra_attendees + 1)
      destroyed_user_id = @user.id
      expect { @user.destroy }.to change{ Attendee.count }.by(expected_difference)

      # double check
      Attendee.where(:user_id => destroyed_user_id).count.should == 0
    end
  end
end
