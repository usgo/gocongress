require "spec_helper"

describe DiscountsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/discounts" }.should route_to(:controller => "discounts", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/discounts/new" }.should route_to(:controller => "discounts", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/discounts/1" }.should route_to(:controller => "discounts", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/discounts/1/edit" }.should route_to(:controller => "discounts", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/discounts" }.should route_to(:controller => "discounts", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/discounts/1" }.should route_to(:controller => "discounts", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/discounts/1" }.should route_to(:controller => "discounts", :action => "destroy", :id => "1")
    end

  end
end
