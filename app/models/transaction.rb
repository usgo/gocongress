class Transaction < ActiveRecord::Base
  attr_accessible :user_id, :trantype, :amount, :gwtranid, :gwdate
  attr_protected :created_at, :updated_at

	belongs_to :user
	
	# Transaction Types:
	# Sale - User makes a payment
	# Discount - Admin reduces total cost for a User (eg. a VIP)
	TRANTYPES = [['Discount','D'], ['Sale','S']]

	validates_presence_of :user_id, :trantype, :amount

	validates_length_of :trantype, :is => 1
  validates_inclusion_of :trantype, :in => TRANTYPES.flatten

	validates_numericality_of :amount
	validates_numericality_of :amount, :greater_than => 0

  # Certain attributes apply only to gateway transaction types (eg. Sale)
  validates_presence_of :gwdate, :if => :is_gateway_trantype?
  validates_date :gwdate, :if => :is_gateway_trantype?
	validates_presence_of :gwtranid, :if => :is_gateway_trantype?
	validates_numericality_of :gwtranid, :if => :is_gateway_trantype?
	validates_uniqueness_of :gwtranid, :if => :is_gateway_trantype?

  # gwdate and gwtranid are only allowed for gateway tranactions
  # ie. not for discounts
  # unfortunately, validating the absence of something is ugly in rails
  GATEWAY_ATTR_MSG = "must be blank for non-gateway transactions"
  with_options :unless => :is_gateway_trantype?, :allow_nil => false, :allow_blank => false, :in => [nil, ''], :message => GATEWAY_ATTR_MSG do |o|
    o.validates_inclusion_of :gwdate
    o.validates_inclusion_of :gwtranid
  end

  def is_gateway_trantype?
    self.trantype != 'D'
  end

  def get_trantype_name
  	trantype_name = ''
    TRANTYPES.each { |t| if (t[1] == self.trantype) then trantype_name = t[0] end }
    if trantype_name.empty? then raise "assertion failed: invalid trantype" end
    return trantype_name
  end
end
