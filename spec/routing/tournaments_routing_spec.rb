require "spec_helper"

describe TournamentsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/tournaments" }.should route_to(:controller => "tournaments", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/tournaments/new" }.should route_to(:controller => "tournaments", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/tournaments/1" }.should route_to(:controller => "tournaments", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/tournaments/1/edit" }.should route_to(:controller => "tournaments", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/tournaments" }.should route_to(:controller => "tournaments", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/tournaments/1" }.should route_to(:controller => "tournaments", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/tournaments/1" }.should route_to(:controller => "tournaments", :action => "destroy", :id => "1")
    end

  end
end
