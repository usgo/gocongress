# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController
  def show
    super do |user|
      if user.errors.empty?
        UserMailer.welcome_email(user).deliver_later
      end
    end
  end
end
