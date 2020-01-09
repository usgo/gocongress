# https://devcenter.heroku.com/articles/config-vars
if ENV['STRIPE_SECRET_KEY'].nil?
  Rails.logger.warn('STRIPE_SECRET_KEY undefined')
end

Stripe.api_key = ENV['STRIPE_SECRET_KEY']
StripeEvent.signing_secret = ENV['STRIPE_SIGNING_SECRET']

StripeEvent.configure do |events|
  events.subscribe 'charge.', Stripe::ChargeEventHandler.new
end