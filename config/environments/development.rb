Gocongress::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  config.eager_load = false

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise error if the mailer can't send?
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets.
  config.assets.compress = false

  # Turn debug mode off to concatenate and preprocess assets.
  config.assets.debug = true

  config.assets.quiet = true

  # Override mailer host in application.rb -Jared 2010.12.27
  config.action_mailer.default_url_options = { :host => "0.0.0.0", :port => "3000" }

  config.web_console.whitelisted_ips = '10.0.0.0/16'
end

