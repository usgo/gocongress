require "rails_helper"
require "cancan/matchers"

RSpec.describe Ability, :type => :model do

  context 'staff' do
    let(:staff) { build :staff }
    subject { Ability.new(staff) }

    it 'can print_cost_summary for users in same year' do
      is_expected.to be_able_to :print_official_docs, build(:user, :year => staff.year)
      is_expected.not_to be_able_to :print_official_docs, build(:user, :year => staff.year - 1)
    end
  end

  describe ".explain_denial" do
    let(:coin_toss) { [true,false].sample }
    it "says you are authenticated" do
      msg = Ability.explain_denial true, :foo, "bar"
      expect(msg).to include 'You are signed in'
    end
    it "says you are not authenticated" do
      msg = Ability.explain_denial false, :foo, "bar"
      expect(msg).to include 'You are not signed in'
    end
    it "includes the action taken and the controller name" do
      msg = Ability.explain_denial coin_toss, :foo, 'bar'
      expect(msg).to include 'foo'
      expect(msg).to include 'bar'
    end
    it "describes create action" do
      msg = Ability.explain_denial coin_toss, :create, 'bananas'
      expect(msg).to include 'create bananas'
    end
    it "describes destroy action" do
      msg = Ability.explain_denial coin_toss, :destroy, 'bananas'
      expect(msg).to include 'delete this banana'
    end
    it "describes index action" do
      msg = Ability.explain_denial coin_toss, :index, 'bananas'
      expect(msg).to include 'list bananas'
    end
    it "describes show action" do
      msg = Ability.explain_denial coin_toss, :show, 'bananas'
      expect(msg).to include 'see this banana'
    end
  end
end
