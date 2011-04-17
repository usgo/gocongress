require "spec_helper"

describe PlanCategoriesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/plan_categories" }.should route_to(:controller => "plan_categories", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/plan_categories/new" }.should route_to(:controller => "plan_categories", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/plan_categories/1" }.should route_to(:controller => "plan_categories", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/plan_categories/1/edit" }.should route_to(:controller => "plan_categories", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/plan_categories" }.should route_to(:controller => "plan_categories", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/plan_categories/1" }.should route_to(:controller => "plan_categories", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/plan_categories/1" }.should route_to(:controller => "plan_categories", :action => "destroy", :id => "1")
    end

  end
end
