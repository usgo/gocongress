class PaymentsController < ApplicationController
  protect_from_forgery

  def new
    @user = current_user
    @amount = params[:amount].gsub(/,/, '').to_f

    intent = Stripe::PaymentIntent.create({
      amount: (@amount * 100).to_i,
      currency: 'usd',
      receipt_email: @user.email,
      metadata: {
        user_id: @user.id
      }
    })

    @client_secret = intent.client_secret
  end

end
