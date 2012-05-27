require "spec_helper"
require "controllers/rpt/shared_examples_for_reports"

describe Rpt::AttendeelessUserReportsController do
  it_behaves_like "a report", %w[html]
end
