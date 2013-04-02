# https://devcenter.heroku.com/articles/config-vars
if ENV['AUTHNET_API_LOGIN_ID'].nil?
  Rails.logger.warn('AUTHNET_API_LOGIN_ID undefined')
end
AUTHORIZE_NET_CONFIG = {
  api_login_id: ENV['AUTHNET_API_LOGIN_ID'],
  api_transaction_key: ENV['AUTHNET_TRANSACTION_KEY'],
  merchant_hash_value: ENV['AUTHNET_MERCHANT_HASH']
}.stringify_keys.freeze
