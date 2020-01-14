require "rails_helper"

RSpec.describe Attendee::WhoIsComing, :type => :model do
  describe '#attendees' do

    it 'excludes attendees with zero plans' do
      a = create :attendee
      expect(Attendee::WhoIsComing.new(a.year).attendees).not_to include(a)
    end

    it 'excludes cancelled attendees' do
      pc = create :plan_category, mandatory: true
      p = create :plan, price: 0, plan_category: pc, description: 'Cancellation'
      a = create :attendee
      a.plans << p
      expect(Attendee::WhoIsComing.new(a.year).attendees).not_to include(a)
    end

    it 'excludes attendees under eighteen' do
      p1 = create :plan, price: 10000

      u = create :user
      adult = create :attendee, user: u
      old_enough = create :teenager, user: u, birth_date: CONGRESS_START_DATE[Time.now.year] - 18.years - 1.days
      not_old_enough = create :teenager, user: u, birth_date: CONGRESS_START_DATE[Time.now.year] - 17.years
      child = create :child, user: u

      # Give the attendees a plan
      adult.plans << p1
      old_enough.plans << p1
      not_old_enough.plans << p1
      child.plans << p1

      create :tr_sale, amount: 40000, user: u
      # Include the adult
      expect(Attendee::WhoIsComing.new(adult.year).attendees).to include(adult, old_enough)
      # Exclude the children
      expect(Attendee::WhoIsComing.new(adult.year).attendees).not_to include(not_old_enough, child)
    end

    it 'returns attendees of users that paid at least $70 and have at least one plan' do
      year = Date.current.year
      csd = CONGRESS_START_DATE[year]
      pc1 = create :plan_category, mandatory: true
      p1 = create :plan, price: 10000
      p2 = create :plan, daily: true, price: 8500, plan_category: pc1
      p3 = create :plan, price: 40000, plan_category: pc1
      p4 = create :plan, price: 4500
      p5 = create :plan, price: 0, plan_category: pc1

      u1 = create :user
      u1a1 = create :attendee, user: u1, given_name: 'u1a'
      u1a1.plans << p1
      create :attendee, user: u1, given_name: 'u1b'
      create :tr_sale, amount: 10000, user: u1

      u2 = create :user
      u2a1 = create :attendee, user: u2, given_name: 'u2a'
      u2a1.plans << p1
      create :attendee, user: u2, given_name: 'u2b'
      create :tr_sale, amount: 9999, user: u2

      u3 = create :user
      u3a1 = create :attendee, user: u3, given_name: 'u3a'
      u3a1ap1 = create :attendee_plan, attendee: u3a1, plan: p2
      create :attendee_plan_date, attendee_plan: u3a1ap1, _date: csd
      create :attendee_plan_date, attendee_plan: u3a1ap1, _date: csd + 1.day
      u3a1.plans << p3 << p4
      u3a2 = create :attendee, user: u3, given_name: 'u3b'
      u3a2.plans << p3
      create :attendee, user: u3, given_name: 'u3c'
      create :tr_sale, amount: 97000, user: u3

      u4 = create :user
      u4a1 = create :attendee, user: u4, given_name: 'u4a'
      u4a1ap1 = create :attendee_plan, attendee: u4a1, plan: p2
      create :attendee_plan_date, attendee_plan: u4a1ap1, _date: csd
      create :attendee_plan_date, attendee_plan: u4a1ap1, _date: csd + 1.day
      u4a1.plans << p3 << p4
      u4a2 = create :attendee, user: u4, given_name: 'u4b'
      u4a2.plans << p3
      create :attendee, user: u4, given_name: 'u4c'
      create :tr_sale, amount: 96999, user: u4

      u5 = create :user
      u5a1 = create :attendee, user: u5, given_name: 'u5a'
      u5a1.plans << p4 << p5

      u6 = create :user
      u6a1 = create :attendee, user: u6, given_name: 'u6a'
      u6a1.plans << p3
      create :attendee, user: u6, given_name: 'u6b'
      create :tr_sale, amount: 7000, user: u6

      u7 = create :user
      u7a1 = create :attendee, user: u7, given_name: 'u7a'
      u7a1.plans << p3
      create :attendee, user: u7, given_name: 'u7b'
      create :tr_sale, amount: 6999, user: u7

      expect(
        Attendee::WhoIsComing.new(u1.year).attendees.map(&:given_name)
      ).to match_array(['u1a', 'u2a', 'u3a', 'u3b', 'u4a', 'u4b', 'u6a'])
    end

    it 'excludes cancelled attendees from unregistered count' do
      a = create :attendee
      cancelled_attendee = create :attendee, cancelled: true

      expect(Attendee::WhoIsComing.new(a.year).unregistered_count).to eq(1)
    end
  end
end
