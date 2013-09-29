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

# In Rails 4 the configuration option in this file has been renamed from
# secret_token to secret_key_base. We’ll need to specify both options while
# we’re transitioning from Rails 3 but once we’ve successfully migrated our
# application we can remove the secret_token option. It’s best to use a
# different token for our secret_key_base.

Gocongress::Application.config.secret_token = UsgcSecretToken.to_s
Gocongress::Application.config.secret_key_base = UsgcSecretToken.to_s
