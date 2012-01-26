require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

# In local dev, Gmail SMTP account will be defined in a file for
# convenience Obviously, this file should never be committed to source
# control Thus, at heroku, this file will not be present For heroku, use
# heroku config:add I'd like to raise an error if GMAIL_SMTP_USER is not
# defined, but that would prevent Heroku from running rake
# assets:precompile because "The app’s config vars are not available in
# the environment during the slug compilation process."
# http://devcenter.heroku.com/articles/rails31_heroku_cedar
usgc_env_file = File.absolute_path "config/usgc_env.rb"
require usgc_env_file if File.file?(usgc_env_file)
puts "Warning: ENV['GMAIL_SMTP_USER'] undefined" if ENV['GMAIL_SMTP_USER'].blank?

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
      :authentication => :plain,
      :domain => ENV['GMAIL_SMTP_USER'],
      :user_name => ENV['GMAIL_SMTP_USER'],
      :password => ENV['GMAIL_SMTP_PASSWORD'],
      :enable_starttls_auto => true
    }

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true

    # We don't want Heroku to try to initialize our models during assets:precompile
    # because on Heroku Cedar, the database is not available during slug compilation.
    # http://stackoverflow.com/questions/8622297/heroku-cedar-assetsprecompile-has-beef-with-attr-protected
    # http://guides.rubyonrails.org/asset_pipeline.html
    config.assets.initialize_on_precompile = false
  end
end
