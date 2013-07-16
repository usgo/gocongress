require 'csv'
require 'pg'

class Exporter
  def initialize
    @conn = activerecord_db_connection
  end

  def db
    @conn
  end

  private

  def assert_pg_connection conn
    unless conn.instance_of?(PG::Connection)
      raise "Expected PG::Connection, got #{conn.class.name}"
    end
  end

  def activerecord_db_connection
    ActiveRecord::Base.connection.raw_connection.tap do |c|
      assert_pg_connection(c)
    end
  end
end
