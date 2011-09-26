class Transaction < ActiveRecord::Base
  attr_accessible :instrument, :user_id, :trantype, :amount, :gwtranid, :gwdate, :check_number, :comment

  # FIXME: in the controller, somehow year needs to get set 
  # before authorize! runs.  until then, year needs to be accessible.
  attr_accessible :year

  # The account this transaction applies to
  belongs_to :user

  # The admin who last updated this transaction
  belongs_to :updated_by_user, :class_name => "User"
	
	# Transaction Types:
	# Comp - Admin reduces total cost for a User (eg. a VIP)
	# Refund - Admin has sent a refund check to a User who overpaid
	# Sale - User makes a payment
	TRANTYPES = [['Comp','C'], ['Refund','R'], ['Sale','S']]
	
	# Instruments
	INSTRUMENTS = [['Card','C'], ['Cash','S'], ['Check','K']]

  scope :for_payment_history, where(:trantype => ['S','R'])

	validates_presence_of :user_id, :trantype, :amount, :updated_by_user, :year
	
  validates_presence_of :instrument, :if => :requires_instrument?
  validates_inclusion_of :instrument, :in => [nil, ''], :if => :forbids_instrument?, \
    :message => "must be blank.  (Not applicable for selected transaction type)"
  validates_length_of :instrument, :is => 1, :if => :requires_instrument?
  validates_inclusion_of :instrument, :in => INSTRUMENTS.flatten, :if => :requires_instrument?

	validates_length_of :trantype, :is => 1
  validates_inclusion_of :trantype, :in => TRANTYPES.flatten

	validates_numericality_of :amount, :greater_than => 0
  validates_numericality_of :year, :only_integer => true, :greater_than => 2010, :less_than => 2100

  # Certain attributes apply only to gateway transaction types (eg. Sale)
  validates_presence_of :gwdate, :if => :is_gateway_transaction?
  validates_date :gwdate, :if => :is_gateway_transaction?
	validates_presence_of :gwtranid, :if => :is_gateway_transaction?
	validates_numericality_of :gwtranid, :if => :is_gateway_transaction?
	validates_uniqueness_of :gwtranid, :if => :is_gateway_transaction?

  # gwdate and gwtranid are only allowed for gateway tranactions, eg. sales
  # unfortunately, validating the absence of something is ugly in rails
  GATEWAY_ATTR_MSG = "must be blank for non-gateway transactions"
  with_options :unless => :is_gateway_transaction?, :allow_nil => false, :allow_blank => false, :in => [nil, ''], :message => GATEWAY_ATTR_MSG do |o|
    o.validates_inclusion_of :gwdate
    o.validates_inclusion_of :gwtranid
  end
  
	validates_numericality_of :check_number, :greater_than => 0, :if => :requires_check_number?

  # Only refunds may have a check number
  validates_inclusion_of :check_number, :unless => :requires_check_number?, \
    :allow_nil => false, :allow_blank => false, :in => [nil, ''], \
    :message => "must be blank.  (Only applicable for Refunds)"

  def requires_instrument?() trantype != 'C' end
  def forbids_instrument?() trantype == 'C' end
  def is_gateway_transaction?() trantype == 'S' and instrument == 'C' end
  def requires_check_number?() instrument == 'K' end

  def get_trantype_name
  	trantype_name = ''
    TRANTYPES.each { |t| if (t[1] == self.trantype) then trantype_name = t[0] end }
    if trantype_name.empty? then raise "assertion failed: invalid trantype" end
    return trantype_name
  end

  def get_instrument_name
    instrument_name = 'Not Applicable'
    INSTRUMENTS.each { |i| if (i[1] == instrument) then instrument_name = i[0] end }
    return instrument_name
  end

  def get_trantype_name_public
    # when speaking to users, we refer to sales as "payments"
    trantype == 'S' ? 'Payment' : get_trantype_name
  end

  def get_ledger_amount
    # on the ledger (payment history) we disply refunds as negative numbers
    trantype == 'R' ? -1 * amount : amount
  end

end
