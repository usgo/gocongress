module DollarController
  extend ActiveSupport::Concern

  module ClassMethods
    def add_filter_converting_param_to_cents cents_attribute
      before_action :only => [:create, :update] do |c|
        c.convert_dollars_to_cents(cents_attribute.to_sym)
      end
    end
  end

  # `convert_dollars_to_cents` takes the name of an element
  # in the model params, eg. `price` in `params[:plan][:price]`.
  # It modifies the param in place, replacing it with the equivalent
  # integer cents.  Note how the American thousands-separator is
  # stripped out before calling `to_f`. -Jared 2012-11-26
  def convert_dollars_to_cents atr
    cnsd = controller_name.singularize.downcase.to_sym
    if params[cnsd][atr].present?
      dollars = params[cnsd][atr].delete(',').to_f
      params[cnsd][atr] = (dollars * 100).round
    end
  end

end
