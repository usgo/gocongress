require 'simplecov'
SimpleCov.start 'rails'

require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = false # TODO: we should verify
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.order = :random
  Kernel.srand config.seed

  config.before do
    # Clear the job queue before each test. I have no idea why `rspec-rails`
    # doesn't do this automatically. I have to do the same thing in my main
    # project at work.
    queue_adapter = ActiveJob::Base.queue_adapter
    queue_adapter.enqueued_jobs.clear
    queue_adapter.performed_jobs.clear
  end
end
