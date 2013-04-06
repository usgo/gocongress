class Transaction < ActiveRecord::Base
  include YearlyModel

  # On the form, admins enter an email, not a user_id,
  # so user_id is not accessible.
  attr_accessible :instrument, :trantype, :amount, :gwtranid, :gwdate,
    :check_number, :comment

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

  # Scopes, and class methods that act like scopes
  scope :comps, where(trantype: 'C')
  scope :for_payment_history, where(:trantype => ['S','R'])

	validates_presence_of :trantype, :amount
	validates :updated_by_user, :presence => true, :on => :update

  validates_presence_of :instrument, :if => :requires_instrument?
  validates_inclusion_of :instrument, :in => [nil, ''], :if => :forbids_instrument?, \
    :message => "must be blank.  (Not applicable for selected transaction type)"
  validates_length_of :instrument, :is => 1, :if => :requires_instrument?
  validates_inclusion_of :instrument, :in => INSTRUMENTS.flatten, :if => :requires_instrument?

	validates_length_of :trantype, :is => 1
  validates_inclusion_of :trantype, :in => TRANTYPES.flatten

	validates_numericality_of :amount, greater_than: 0, only_integer: true

  # Certain attributes apply only to gateway transaction types (eg. Sale)
  with_options :if => :is_gateway_transaction? do |gwt|
    gwt.validates :gwdate, :presence => true
    gwt.validates_date :gwdate

    # Now that we've switched to authorize.net, we no longer
    # validate the uniqueness of `gwtranid`.  This is because when
    # the account is in "test" mode, the returned transaction id is
    # always zero. -Jared 2013-04-06
    gwt.validates :gwtranid, \
      :presence => true, \
      :numericality => { :less_than => 9223372036854775807 }
  end

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

  # The user presence validation message refers to email address because
  # the transaction form has an email field to select the user.
  validates :user, :presence => { :message => " email address is blank
    or incorrect.  Please make sure to enter the email address of the
    correct user account."}

  def self.create_from_authnet_sim_response rsp
    user = User.find(rsp.customer_id) # x_cust_id
    t = new
    t.trantype = 'S' # Sale
    t.instrument = 'C' # Card
    t.user = user
    t.year = user.year
    t.amount = (rsp.fields[:amount].to_f * 100).round # convert to cents
    t.gwtranid = rsp.transaction_id # x_trans_id
    t.gwdate = Date.current
    t.save!
  end

  def requires_instrument?() trantype != 'C' end
  def forbids_instrument?() trantype == 'C' end
  def is_gateway_transaction?() trantype == 'S' and instrument == 'C' end
  def requires_check_number?() instrument == 'K' end

  def description
    get_trantype_name_public + (comment.blank? ? '' : ": #{comment}")
  end

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

  # Only comps appear on invoices.  Refunds and sales appear on the
  # ledger (payment history)
  def to_invoice_item
    if trantype == 'C'
      InvoiceItem.new(description, 'N/A', -1 * amount, 1)
    else
      raise "Non-invoiced transaction type: #{trantype}"
    end
  end

end
