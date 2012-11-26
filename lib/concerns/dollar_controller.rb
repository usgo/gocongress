module DollarController
  extend ActiveSupport::Concern

  module ClassMethods
    def add_filter_converting_param_to_cents cents_attribute
      before_filter :only => [:create, :update] do |c|
        c.convert_dollars_to_cents(cents_attribute.to_sym)
      end
    end
  end

  def convert_dollars_to_cents atr
    cnsd = controller_name.singularize.downcase.to_sym
    if params[cnsd][atr].present?
      params[cnsd][atr] = (params[cnsd][atr].to_f * 100).round
    end
  end

end
