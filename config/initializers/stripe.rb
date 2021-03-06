# https://devcenter.heroku.com/articles/config-vars
if ENV['STRIPE_PUBLISHABLE_KEY'].nil?
  Rails.logger.warn('STRIPE_PUBLISHABLE_KEY undefined')
end

if ENV['STRIPE_SECRET_KEY'].nil?
  Rails.logger.warn('STRIPE_SECRET_KEY undefined')
end

::STRIPE_PUBLISHABLE_KEY = ENV['STRIPE_PUBLISHABLE_KEY']
Stripe.api_key = ENV['STRIPE_SECRET_KEY']
StripeEvent.signing_secret = ENV['STRIPE_SIGNING_SECRET']

# Using `reloader.to_prepare` per
# https://github.com/integrallis/stripe_event/issues/134
Rails.application.reloader.to_prepare do
  StripeEvent.configure do |events|
    events.subscribe 'charge.', Stripe::ChargeEventHandler.new
  end
end
