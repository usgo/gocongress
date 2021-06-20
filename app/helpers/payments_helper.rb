module PaymentsHelper
  def dev?
    Rails.env == 'development'
  end
end
