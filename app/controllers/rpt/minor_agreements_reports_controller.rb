class Rpt::MinorAgreementsReportsController < Rpt::AbstractReportController

def show
  @minors_without_agreements = Attendee.yr(@year)
    .where(
      "birth_date > ? and minor_agreement_received = false",
      CONGRESS_START_DATE[@year.to_i] - 18.years
    )
  @minors_with_agreements = Attendee.yr(@year)
    .where(
      "birth_date > ? and minor_agreement_received = true",
      CONGRESS_START_DATE[@year.to_i] - 18.years
    )

  @congress_start_date = CONGRESS_START_DATE[@year.to_i]
end

end
