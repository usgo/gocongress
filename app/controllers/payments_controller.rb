class PaymentsController < ApplicationController
  helper :authorize_net
  protect_from_forgery :except => :relay_response

  before_filter :assert_config

  def new
    @amount = 10.00
    @sim_transaction = AuthorizeNet::SIM::Transaction.new(
      AUTHORIZE_NET_CONFIG['api_login_id'],
      AUTHORIZE_NET_CONFIG['api_transaction_key'],
      @amount,
      :relay_url => environment_aware_relay_url)
  end

  # POST
  # Returns relay response when Authorize.Net POSTs to us.
  def relay_response
    sim_response = AuthorizeNet::SIM::Response.new(params)
    if sim_response.success?(AUTHORIZE_NET_CONFIG['api_login_id'], AUTHORIZE_NET_CONFIG['merchant_hash_value'])
      render :text => sim_response.direct_post_reply(payments_receipt_url(:only_path => false), :include => true)
    else
      render :layout => false
    end
  end

  # GET
  # Displays a receipt.
  def receipt
    @auth_code = params[:x_auth_code]
  end

  private

  def assert_config
    conf = AUTHORIZE_NET_CONFIG
    if conf['api_login_id'].nil? || conf['api_transaction_key'].nil?
      raise "authnet config is missing"
    end
  end

  # When developing locally, we want to specify a dyndns
  # hostname and use NAT, in order to get the relay response.
  # -Jared 2013-02-16
  def environment_aware_relay_url
    opts = {}
    if ENV['AUTHNET_RELAY_HOST'].present?
      opts = { host: ENV['AUTHNET_RELAY_HOST'], port: nil }
    end
    payments_relay_response_url(opts)
  end
end
