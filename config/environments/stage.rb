require_relative 'shared/notifier'

Gocongress::Application.configure do

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Asset sync
  config.action_controller.asset_host = "//#{ENV['FOG_DIRECTORY']}.s3.amazonaws.com"

  # Disable Rails's static asset server
  config.serve_static_files = false

  # Compress JavaScripts and CSS.
  config.assets.compress = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache

  # Disable delivery errors, bad email addresses will be ignored.
  config.action_mailer.raise_delivery_errors = true

  # Staging host differs from production host -Jared 2011-12-12
  config.action_mailer.default_url_options = { :host => "gocongress-dev.herokuapp.com" }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found)
  config.i18n.fallbacks = [I18n.default_locale]

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  config.force_ssl = true

  # Runtime exception notification
  GocongressNotifier.use_exception_notifier_middleware(config)
end
