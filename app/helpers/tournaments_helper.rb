module TournamentsHelper

  def link_to_destroy(tournament)
    link_to 'Delete' \
      , tournament_path(@year, tournament) \
      , :confirm => I18n.translate('crud.confirm.tournament.destroy') \
      , :method => :delete
  end

end
