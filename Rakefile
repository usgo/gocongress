# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake/dsl_definition'
require 'rake'

Gocongress::Application.load_tasks

# Invoke db:seed after db:prepare
namespace :db do
  namespace :test do
    task :prepare => :environment do
      Rake::Task["db:seed"].invoke
    end
  end
end

# I'm not sure how it happened, but I ran into a disturbing problem where
# my postgres sequences started over at one.  Naturally, this caused
# inserts to fail.  This shotgun-approach solution fixed my sequences.
# I sincerely hope this only ever happens to my development database.
# Knock on wood. -Jared 2011-11-07
namespace :db do
  desc "Reset all sequences. Run after data imports"
  task :reset_sequences, [:model_class] => [:environment] do |t, args|
    if args[:model_class]
      classes = Array(eval args[:model_class])
    else
      puts "using all defined active_record models"
      classes = []
      Dir.glob(Rails.root.to_s + '/app/models/*.rb').each { |file| require file }
      ActiveRecord::Base.subclasses.select { |c|c.base_class == c}.sort_by(&:name).each do |klass|
        classes << klass
      end
    end
    classes.each do |klass|
      puts "reseting sequence on #{klass.table_name}"
      ActiveRecord::Base.connection.reset_pk_sequence!(klass.table_name)
    end
  end
end

# Turn off rspec verbosity, so that the command is not echoed to
# stdout. http://bit.ly/MoOoB3  -Jared 2012-07-19
if defined? RSpec
  task(:spec).clear
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.verbose = false
  end
end

# Default task: lint then test
task default: [] # in case it hasn't been set
Rake::Task[:default].clear
task default: [:rubocop, :spec]
