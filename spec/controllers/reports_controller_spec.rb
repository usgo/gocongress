require 'spec_helper'

describe ReportsController do

  describe "GET 'emails'" do
    it "should be successful" do
      get 'emails'
      response.should be_success
    end
  end

end
