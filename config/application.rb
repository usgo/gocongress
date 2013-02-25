require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Gocongress
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # action_mailer's default_url_options should not be confused with
    # ActionController#default_url_options().  Unlike in ActionController, we
    # can only set static values here, and we can only use what's available
    # during initialization.  Specifically, this means that we cannot specify
    # a deafult year, as we do in ActionController.  -Jared 2012-01-18
    config.action_mailer.default_url_options = { :host => "www.gocongress.org" }
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      :address => "smtp.gmail.com",
      :port => 587,
      :authentication => 'plain',
      :user_name => ENV['GMAIL_SMTP_USER'],
      :password => ENV['GMAIL_SMTP_PASSWORD'],
      :enable_starttls_auto => true
    }

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(
      #{Rails.root}/lib
      #{Rails.root}/lib/concerns
    )

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Some libraries have JS, CSS, and images.  It's a hassle
    # to split these libs up, so we keep them whole in a libs dir.
    config.assets.paths << "#{Rails.root}/vendor/assets/libs"

    # We don't want Heroku to try to initialize our models during assets:precompile
    # because on Heroku Cedar, the database is not available during slug compilation.
    # http://stackoverflow.com/questions/8622297/heroku-cedar-assetsprecompile-has-beef-with-attr-protected
    # http://guides.rubyonrails.org/asset_pipeline.html
    config.assets.initialize_on_precompile = false
  end
end
