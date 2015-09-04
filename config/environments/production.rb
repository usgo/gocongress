require_relative 'shared/notifier'

Gocongress::Application.configure do

  config.eager_load = true

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Asset sync
  config.action_controller.asset_host = "//#{ENV['FOG_DIRECTORY']}.s3.amazonaws.com"

  # Mass assignment protection for Active Record models
  # See ActiveModel::MassAssignmentSecurity::ClassMethods
  config.active_record.mass_assignment_sanitizer = :logger

  # Disable Rails's static asset server
  config.serve_static_files = false

  # Compress JavaScripts and CSS.
  config.assets.compress = true

  # enables the use of MD5 fingerprints in asset names
  config.assets.digest = true

  # Specifies the header that your server uses for sending files.
  config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache

  config.log_level = :info

  # Disable delivery errors, bad email addresses will be ignored.
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { :host => "www.gocongress.org" }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Runtime exception notification
  GocongressNotifier.use_exception_notifier_middleware(config)

end
