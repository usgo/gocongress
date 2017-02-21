if defined? RuboCop
  require "rubocop/rake_task"
  desc "Run RuboCop on the lib directory"
  RuboCop::RakeTask.new
end
