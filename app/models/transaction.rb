class Transaction < ActiveRecord::Base

	belongs_to :user
	
	validates_presence_of :user_id, :trantype, :amount, :gwtranid, :gwdate
	validates_length_of :trantype, :is => 1
	validates_numericality_of :amount, :gwtranid
	validates_numericality_of :amount, :greater_than => 0, :if => :amount_must_be_positive?
	validates_uniqueness_of :gwtranid
	
	# define constant array of trantypes
	TRANTYPES = [['Sale', 'S']]

  def amount_must_be_positive?
    self.trantype == 'S'
  end

  def get_trantype_name
  	trantype_name = ''
    TRANTYPES.each { |t| if (t[1] == self.trantype) then trantype_name = t[0] end }
    if trantype_name.empty? then raise "assertion failed: invalid trantype" end
    return trantype_name
  end
end
