# lib/tasks/temporary/attendees.rake
namespace :attendees do
  desc "Migrate sms plans to receive_sms attribute for attendees"
  task migrate_sms_plans: :environment do

    attendees_with_sms_plans = Attendee.select('attendees.id, attendees.phone, attendees.local_phone, attendees.receive_sms').joins(:plans).where('plans.name = ?', "Yes! SMS!")

    puts <<-TEXT
    Going to migrate #{attendees_with_sms_plans.to_a.count} attendees from "Yes! SMS!" plan to Attendee receive_sms attribute set to true
    TEXT

    ActiveRecord::Base.transaction do
      attendees_with_sms_plans.each do |a|
        a.update_attribute :receive_sms, true
        print "."
      end
    end
    puts " All done now!"
  end
end
