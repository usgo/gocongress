require "spec_helper"

describe PlansController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/plans" }.should route_to(:controller => "plans", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/plans/new" }.should route_to(:controller => "plans", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/plans/1" }.should route_to(:controller => "plans", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/plans/1/edit" }.should route_to(:controller => "plans", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/plans" }.should route_to(:controller => "plans", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/plans/1" }.should route_to(:controller => "plans", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/plans/1" }.should route_to(:controller => "plans", :action => "destroy", :id => "1")
    end

  end
end
