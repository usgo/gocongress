require "rails_helper"

RSpec.describe User, :type => :model do
  it_behaves_like "a yearly model"

  context "when initialized" do
    it "is not yet valid" do
      expect(User.new).not_to be_valid
    end
  end

  describe "#amount_paid" do
    it "equals the total of sales minus the total of refunds" do
      user = create :user
      sales = 1.upto(3).map{ create :tr_sale, user_id: user.id }
      refunds = 1.upto(3).map{ create :tr_refund, user_id: user.id }
      sale_total = sales.map(&:amount).reduce(:+)
      refund_total = refunds.map(&:amount).reduce(:+)
      expect(user.amount_paid).to eq(sale_total - refund_total)
    end
  end

  describe "attendeeless scope" do
    it "returns only users with no attendees" do
      a1 = create :attendee
      u1 = a1.user
      u2 = create :user
      expect(u2.attendees).to be_empty
      expect(User.attendeeless).to eq([u2])
    end
  end

  describe "#balance" do
    it "equals invoice total minus amount paid" do
      u = build :user
      allow(u).to receive(:get_invoice_total) { 7 }
      allow(u).to receive(:amount_paid) { 9 }
      expect(u.balance).to eq(-2)
    end
  end

  describe 'email' do
    let(:capital) { 'Asdf@example.com' }

    it 'is downcased when saved' do
      u = create(:user, email: capital)
      expect(u.reload.email).to eq(capital.downcase)
      expect(User.where(email: capital.downcase).first).to eq(u)
      expect(User.where(email: capital).first).to eq(nil)
    end
  end

  describe "#invoice_items" do
    let(:attendee) { create :attendee }
    let(:user) { attendee.user }

    it "includes invoice items from all attendees" do
      create :attendee, :user => user
      items = [:foo, :bar]
      allow_any_instance_of(Attendee).to receive(:invoice_items) { items }
      expect(user.invoice_items).to match_array(items * 2)
    end

    it "includes comp transactions" do
      comp = create(:tr_comp, :user => user, :amount => 777)
      items = user.invoice_items
      expect(items.size).to eq(1)
      expect(items.first.price).to eq(comp.amount * -1)
    end
  end

  it "has a valid factory" do
    expect(build(:user)).to be_valid
  end

  describe '#valid' do
    it "is invalid if email is invalid" do
      user = build :user, :email => "herpderp"
      expect(user).not_to be_valid
      expect(user.errors).to include(:email)
    end

    it "is invalid if email is not unique" do
      extant = create :user, :email => "John@example.com"
      user = build :user, {email: extant.email, year: extant.year}
      expect(user).not_to be_valid
      expect(user.errors).to include(:email)
    end

    it "returns false if password is blank" do
      expect(build(:user, :password => "")).to have_error_about(:password)
    end

    it "returns false if password is too short" do
      expect(build(:user, :password => "12345")).to have_error_about(:password)
    end

    it "returns false if the password is not confirmed" do
      expect(build(:user, :password_confirmation => "")).to \
        have_error_about(:password_confirmation)
    end
  end

  describe "#get_invoice_total" do

    it "equals the sum of invoice items" do
      user = build :user
      allow(user).to receive(:invoice_items) {[
        InvoiceItem.new("Baubles", "John", 1.5, 2),
        InvoiceItem.new("Trinkets", "Jane", -0.75, 1)
      ]}
      expect(user.get_invoice_total).to eq(2.25)
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
      expect(actual).to be_within(0.001).of(expected)

      # change plan qty by 1, assert that invoice total changes by price
      expected = user.get_invoice_total + p.price
      ap.quantity += 1
      ap.save
      expect(user.get_invoice_total).to be_within(0.001).of(expected)
    end

  end

  describe '#destroy' do
    it "destroying a user destroys all dependent attendees" do
      user = create :user
      num_attendees = 1 + rand(3)
      num_attendees.times do |t|
        user.attendees << create(:attendee, :user => user)
      end
      expect { user.destroy }.to change{ Attendee.count }.by(-1 * num_attendees)
      expect(Attendee.where(:user_id => user.id)).to be_empty
    end
  end
end
