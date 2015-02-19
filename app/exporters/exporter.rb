require 'csv'
require 'pg'

class Exporter
  def initialize
    @conn = activerecord_db_connection
  end

  def matrix_to_csv(m)
    CSV.generate { |csv| m.each { |row| csv << row } }
  end

  def db
    @conn
  end

  protected

  def sql filename_no_ext
    File.read sql_path filename_no_ext
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

  def sql_path filename_no_ext
    File.join(File.dirname(__FILE__), filename_no_ext + '.sql')
  end
end
