class EditableText < ApplicationRecord
  include YearlyModel
  after_initialize :init

  def init
    if self.has_attribute? :attendees_vip
      self.attendees_vip ||= I18n.t('gocongress.editable_text.attendees_vip')
    end

    if self.has_attribute? :volunteers
      self.volunteers ||= I18n.t('gocongress.editable_text.volunteers')
    end

    if self.has_attribute? :welcome
      self.welcome ||= I18n.t('gocongress.editable_text.welcome')
    end
  end
end
