require_relative '../../app/services/who_is_coming'

describe WhoIsComing do
  describe '#attendees' do
    it 'returns attendees that paid deposit and have at least one plan' do
      p = create :plan

      u1 = create :user
      u1a = create :attendee, user: u1, given_name: 'u1a', plans: [p]
      u1b = create :attendee, user: u1, given_name: 'u1b'
      create :tr_sale, amount: 20000, user: u1

      u2 = create :user
      u2a = create :attendee, user: u2, given_name: 'u2a', plans: [p]
      u2b = create :attendee, user: u2, given_name: 'u2b'
      create :tr_sale, amount: 19999, user: u2

      WhoIsComing.attendees(u1.year).map(&:given_name).should == ['u1a']
    end
  end
end
