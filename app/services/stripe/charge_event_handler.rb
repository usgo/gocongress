module Stripe
    class ChargeEventHandler
        def call(event)
            begin
                method = "handle_" + event.type.tr('.', '_')
                self.send method, event
            rescue JSON::ParserError => e
                # handle the json parsing error here
                raise # re-raise the exception to return a 500 error to stripe
            rescue NoMethodError => e
                #code to run when handling an unknown event
            end
        end

        def handle_charge_failed(event)
            # Placeholder for handling failed charges
        end

        def handle_charge_succeeded(event)
            Transaction.create_from_stripe_webhook(event.data.object)
        end
    end
end