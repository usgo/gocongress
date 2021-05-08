class EditableText < ApplicationRecord
  include YearlyModel
  after_initialize :init

  def init
    if self.has_attribute? :attendees_vip
      self.attendees_vip ||= "Professional Go teachers will attend the 2021 U.S. Go Congress. As the list of attending Pros is created, descriptions of them will appear on this webpage."
    end

    if self.has_attribute? :volunteers
      self.volunteers ||= "From **tournament directors** to the people who volunteer **only a few hours at the front desk**, we need your help.  The Go Congress would not be possible without the dedication of dozens of volunteers.  Please email the congress directors to volunteer at this year’s congress. Thanks!"
    end

    if self.has_attribute? :welcome
      self.welcome ||= "The U.S. Go Congress is the largest go activity in the United States. It happens once a year and spans one week. Events include the U.S. Open, the largest annual go tournament in the U.S., professional lectures and game analysis, continuous self-paired games, and all kinds of go-related activities from morning to midnight. Come for the go. Come for the camaraderie of old friends. Whatever your reason, we are looking forward to seeing you there."
    end
  end
end
