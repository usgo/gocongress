module TournamentsHelper

  def button_to_sign_up(user)
    button_to 'Sign Up for Tournaments',
      choose_attendee_user_path(current_user),
      :method => "get"
  end

  def link_to_destroy(tournament)
    link_to 'Delete' \
      , tournament_path(tournament) \
      , :data => {:confirm => I18n.translate('crud.confirm.tournament.destroy')} \
      , :method => :delete
  end

end
