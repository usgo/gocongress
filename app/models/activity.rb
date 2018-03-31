class Activity < ApplicationRecord
  include YearlyModel
  include Purchasable

  belongs_to :activity_category
  has_many :attendee_activities, :dependent => :destroy
  has_many :attendees, :through => :attendee_activities

  validates :activity_category, :presence => true
  validates_presence_of :leave_time, :name, :return_time
  validates :location, :length => {:maximum => 50}
  validates :notes, :length => {
    :maximum => 2000,
    :message => "are too long (maximum is 2000 characters)"
  }
  validates :phone, :length => {:maximum => 20}
  validates :price, :numericality => {
    :equal_to => 0,
    :if => :price_varies?,
    :message => " - You have indicated that the price varies. Please
      set the price to 0, so that this #{model_name.human.downcase}
      will not show up on invoices."
  }
  validates :url, :length => {:maximum => 200},
    :format => {
      :with => /\Ahttps?:\/{2}/,
      :allow_blank => true,
      :message => "must begin with protocol, eg. http://"}

  scope :disabled, -> { where(disabled: true) }

  def to_invoice_item attendee_full_name
    InvoiceItem.new(name, attendee_full_name, price, 1)
  end
end
