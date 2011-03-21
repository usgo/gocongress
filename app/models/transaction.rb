class Transaction < ActiveRecord::Base
  attr_accessible :user_id, :trantype, :amount, :gwtranid, :gwdate
  attr_protected :created_at, :updated_at

	belongs_to :user
	
	# Transaction Types:
	# Sale - User makes a payment
	# Discount - Admin reduces total cost for a User (eg. a VIP)
	TRANTYPES = [['Discount','D'], ['Sale','S']]

	validates_presence_of :user_id, :trantype, :amount, :gwdate

	validates_length_of :trantype, :is => 1
  validates_inclusion_of :trantype, :in => TRANTYPES.flatten

	validates_numericality_of :amount
	validates_numericality_of :amount, :greater_than => 0
	
	# gateway transaction id is required, except for discounts
	validates_presence_of :gwtranid, :if => :is_gateway_trantype?
	validates_numericality_of :gwtranid, :if => :is_gateway_trantype?
	validates_uniqueness_of :gwtranid, :if => :is_gateway_trantype?

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
