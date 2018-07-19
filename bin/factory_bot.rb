ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
begin
  DatabaseCleaner.start
  FactoryBot.lint(traits: true)
ensure
  DatabaseCleaner.clean
end
