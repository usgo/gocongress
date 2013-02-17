# AUTHORIZE_NET_CONFIG = yml['default']
# AUTHORIZE_NET_CONFIG.merge!(yml[RAILS_ENV]) unless yml[RAILS_ENV].nil?

# https://devcenter.heroku.com/articles/config-vars
AUTHORIZE_NET_CONFIG = {
  api_login_id: ENV['AUTHNET_API_LOGIN_ID'],
  api_transaction_key: ENV['AUTHNET_TRANSACTION_KEY'],
  merchant_hash_value: ENV['AUTHNET_API_LOGIN_ID']
}.stringify_keys.freeze
