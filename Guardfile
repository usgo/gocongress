# https://github.com/guard/guard#readme

guard 'spork', {
    :bundler => true,
    :cucumber => false,
    :rspec => true,
    :rspec_env => { 'RAILS_ENV' => 'test' },
    :test_unit => false,
    :quiet => true
    } do
  watch('config/application.rb')
  watch('config/environment.rb')
  watch('config/environments/test.rb')
  watch(%r{^config/initializers/.+\.rb$})
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('spec/spec_helper.rb') { :rspec }
  watch('test/test_helper.rb') { :test_unit }
  watch(%r{features/support/}) { :cucumber }
end

guard 'rspec', {
    :all_after_pass => false,
    :all_on_start => false,
    :cli => "--drb"
    } do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }

  # Rails example
  watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^app/(.*)(\.erb|\.haml)$})                 { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
  watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance/#{m[1]}_spec.rb"] }
  watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
  watch('app/controllers/application_controller.rb')  { "spec/controllers" }

  # Gocongress-specific
  watch('app/exporters/attendees_csv_exporter.rb') {
    'spec/controllers/rpt/attendee_reports_controller_spec.rb'
  }
  watch('app/presenters/shirt_menu.rb') { 'spec/features/attendee_form_spec.rb' }
end
