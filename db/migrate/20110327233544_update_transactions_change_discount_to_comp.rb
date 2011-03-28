class UpdateTransactionsChangeDiscountToComp < ActiveRecord::Migration
  class Transaction < ActiveRecord::Base
  end

  def self.up
    Transaction.update_all "trantype = 'C'", "trantype = 'D'"
  end

  def self.down
    Transaction.update_all "trantype = 'D'", "trantype = 'C'"
  end
end
