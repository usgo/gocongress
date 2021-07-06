class AmountsToCents < ActiveRecord::Migration
  # Represent all currency values in cents instead of dollars.
  # This migration uses some feature which may be specific to
  # Postgres, eg. `alter table rename column`
  # -Jared 2012-11-25

  def up
    dollars_to_cents :activities, :price
    dollars_to_cents :discounts, :amount
    dollars_to_cents :plans, :price
    dollars_to_cents :transactions, :amount
  end

  def down
    cents_to_dollars :activities, :price
    cents_to_dollars :discounts, :amount
    cents_to_dollars :plans, :price
    cents_to_dollars :transactions, :amount
  end

  def dollars_to_cents(table, column)
    execute "alter table #{table} add #{column}_in_cents integer"
    execute "update #{table} set #{column}_in_cents = round(#{column} * 100)"
    execute "alter table #{table} alter column #{column}_in_cents set not null"
    execute "alter table #{table} drop #{column}"
    execute "alter table #{table} rename column #{column}_in_cents to #{column}"
  end

  def cents_to_dollars(table, column)
    execute "alter table #{table} add #{column}_in_dollars numeric(10,2);"
    execute "update #{table} set #{column}_in_dollars = #{column} / 100;"
    execute "alter table #{table} alter column #{column}_in_dollars set not null;"
    execute "alter table #{table} drop #{column};"
    execute "alter table #{table} rename column #{column}_in_dollars to #{column};"
  end
end
