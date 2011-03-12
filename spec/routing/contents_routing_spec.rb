require "spec_helper"

describe ContentsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/contents" }.should route_to(:controller => "contents", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/contents/new" }.should route_to(:controller => "contents", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/contents/1" }.should route_to(:controller => "contents", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/contents/1/edit" }.should route_to(:controller => "contents", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/contents" }.should route_to(:controller => "contents", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/contents/1" }.should route_to(:controller => "contents", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/contents/1" }.should route_to(:controller => "contents", :action => "destroy", :id => "1")
    end

  end
end
