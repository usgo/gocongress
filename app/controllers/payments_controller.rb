class PaymentsController < ApplicationController
  helper :authorize_net
  protect_from_forgery :except => :relay_response

  before_filter :assert_config

  def new
    authorize! :new, :authnet_payment
    @amount = params[:amount].to_f
    @sim_transaction = AuthorizeNet::SIM::Transaction.new(
      conf('api_login_id'),
      conf('api_transaction_key'),
      @amount,
      :relay_url => environment_aware_relay_url)
  end

  # After processing the payment form submission, Authorize.Net
  # POSTs to `relay_response`.  This request will not have the
  # session cookie.  We respond with HTML containing
  # a JS window.location redirect (and meta-refresh fallback) to
  # the `#receipt` action.
  def relay_response
    sim_response = AuthorizeNet::SIM::Response.new(params)
    if sim_response.success?(conf('api_login_id'), conf('merchant_hash_value'))
      render_js_redirect_to_receipt(sim_response)
    else
      render :layout => false
    end
  end

  def receipt
    authorize! :receipt, :authnet_payment
    @auth_code = params[:x_auth_code]
  end

  private

  def assert_config
    conf = AUTHORIZE_NET_CONFIG
    if conf['api_login_id'].nil? || conf['api_transaction_key'].nil?
      raise "authnet config is missing"
    end
    if Rails.env == 'development' && ENV['AUTHNET_RELAY_HOST'].blank?
      raise "configure authnet relay host for local dev"
    end
  end

  def conf key
    AUTHORIZE_NET_CONFIG[key]
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

  # Render a JS window.location redirect (and meta-refresh fallback)
  def render_js_redirect_to_receipt sim_response
    render :text => sim_response.direct_post_reply(
      payments_receipt_url(:only_path => false), :include => true)
  end
end
