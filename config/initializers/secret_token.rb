# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.

module UsgcSecretToken
  def self.local?
    Rails.env.development? or Rails.env.test?
  end

  # minimum length: 30 chars
  def self.to_s
    local? ? ('x' * 30) : ENV['RAILS_SECRET_TOKEN']
  end
end

Gocongress::Application.config.secret_token = UsgcSecretToken.to_s
