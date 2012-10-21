require_relative 'shared/notifier'

Gocongress::Application.configure do

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Mass assignment protection for Active Record models
  # See ActiveModel::MassAssignmentSecurity::ClassMethods
  config.active_record.mass_assignment_sanitizer = :logger

  # Disable Rails's static asset server
  config.serve_static_assets = false

  # Compress JavaScripts and CSS.
  config.assets.compress = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache

  # Disable delivery errors, bad email addresses will be ignored.
  config.action_mailer.raise_delivery_errors = false

  # Staging host differs from production host -Jared 2011-12-12
  config.action_mailer.default_url_options = { :host => "gocongress-dev.heroku.com" }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Runtime exception notification
  GocongressNotifier.use_exception_notifier_middleware(config)

end
