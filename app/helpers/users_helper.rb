module UsersHelper

  def role_emphasis_class user
    if user.admin?
      'emphasis-strong'
    elsif user.staff?
      'emphasis'
    else
      'emphasis-none'
    end
  end

  def user_account_title user, page
    if signed_in? && current_user == user
      "My #{page}"
    elsif user.primary_attendee.present?
      "#{user.full_name_possessive} #{page}"
    else
      page
    end
  end

end
