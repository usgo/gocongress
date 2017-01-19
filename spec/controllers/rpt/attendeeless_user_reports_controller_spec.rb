require "rails_helper"
require "controllers/rpt/shared_examples_for_reports"

RSpec.describe Rpt::AttendeelessUserReportsController, :type => :controller do
  it_behaves_like "a report", %w[html]
end
