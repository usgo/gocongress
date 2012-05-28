require "spec_helper"
require "controllers/rpt/shared_examples_for_reports"

describe Rpt::AttendeeReportsController do
  it_behaves_like "a report", %w[html csv]
end
