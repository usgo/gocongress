class PaymentsController < ApplicationController
  helper :authorize_net
  protect_from_forgery :except => :relay_response

  before_filter :assert_config

  # To save money, we're using Heroku's piggyback SSL, so we're
  # sending users to https://gocongress.herokuapp.com/payments/new.
  # Because the domain name changes, they will *not* supply cookies.
  # Thus, current_user will be nil.  Therefore, we pass the user id
  # in the params. -Jared 2013-04-07
  def new
    unless userid_in_params?
      redirect_to_new_payment_url && return
    end
    @user = User.find params[:user_id].to_i
    @amount = params[:amount].to_f
    @sim_transaction = AuthorizeNet::SIM::Transaction.new(
      conf('api_login_id'),
      conf('api_transaction_key'),
      @amount,
      :relay_url => environment_aware_relay_url)
    @sim_transaction.set_fields({:cust_id => @user.id})
  end

  # After processing the payment form submission, Authorize.Net
  # POSTs to `relay_response`.  This request will not have the
  # session cookie.  We respond with HTML containing
  # a JS window.location redirect (and meta-refresh fallback) to
  # the `#receipt` action.
  def relay_response
    @sim_response = AuthorizeNet::SIM::Response.new(params)
    if @sim_response.success?(conf('api_login_id'), conf('merchant_hash_value'))
      begin
        Transaction.create_from_authnet_sim_response(@sim_response)
        render_js_redirect_to_receipt(@sim_response, true)
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
        render_js_redirect_to_receipt(@sim_response, false, e.to_s)
      end
    else
      render :layout => false
    end
  end

  def receipt
    @auth_code = params[:x_auth_code]
    @transaction_saved = params[:transaction_saved] == 'true'
    @error_msg = params[:error_msg] || ""
  end

  private

  def userid_in_params?
    params[:user_id].to_i > 0
  end

  # Before entering CC info, users are redirected to
  # gocongress.herokuapp.com, where we can serve the form over SSL.
  # When they finish paying, they are asked to return to gocongress.org
  # because that's where their cookies were set.  If they don't follow
  # instructions, just redirect them.  These are the hoops we must jump
  # through to get free SSL :-)  Note that the host for this redirect
  # URL will come from `default_url_options` -Jared 2013
  def redirect_to_new_payment_url
    redirect_to new_payment_url(:protocol => 'http')
  end

  def assert_config
    conf = AUTHORIZE_NET_CONFIG
    if conf['api_login_id'].blank? || conf['api_transaction_key'].blank? || conf['merchant_hash_value'].blank?
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
  def render_js_redirect_to_receipt sim_response, transaction_saved, error_msg = nil
    url = payments_receipt_url(
      :transaction_saved => transaction_saved,
      :error_msg => error_msg,
      :only_path => false)
    render :text => sim_response.direct_post_reply(url, :include => true)
  end
end
