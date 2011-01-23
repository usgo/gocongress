require 'spec_helper'

describe PlansController do

  def mock_plan(stubs={})
    (@mock_plan ||= mock_model(Plan).as_null_object).tap do |plan|
      plan.stub(stubs) unless stubs.empty?
    end
  end

  describe "GET index" do
    it "assigns all plans as @plans" do
      Plan.stub(:all) { [mock_plan] }
      get :index
      assigns(:plans).should eq([mock_plan])
    end
  end

  describe "GET show" do
    it "assigns the requested plan as @plan" do
      Plan.stub(:find).with("37") { mock_plan }
      get :show, :id => "37"
      assigns(:plan).should be(mock_plan)
    end
  end

  describe "GET new" do
    it "assigns a new plan as @plan" do
      Plan.stub(:new) { mock_plan }
      get :new
      assigns(:plan).should be(mock_plan)
    end
  end

  describe "GET edit" do
    it "assigns the requested plan as @plan" do
      Plan.stub(:find).with("37") { mock_plan }
      get :edit, :id => "37"
      assigns(:plan).should be(mock_plan)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created plan as @plan" do
        Plan.stub(:new).with({'these' => 'params'}) { mock_plan(:save => true) }
        post :create, :plan => {'these' => 'params'}
        assigns(:plan).should be(mock_plan)
      end

      it "redirects to the created plan" do
        Plan.stub(:new) { mock_plan(:save => true) }
        post :create, :plan => {}
        response.should redirect_to(plan_url(mock_plan))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved plan as @plan" do
        Plan.stub(:new).with({'these' => 'params'}) { mock_plan(:save => false) }
        post :create, :plan => {'these' => 'params'}
        assigns(:plan).should be(mock_plan)
      end

      it "re-renders the 'new' template" do
        Plan.stub(:new) { mock_plan(:save => false) }
        post :create, :plan => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested plan" do
        Plan.should_receive(:find).with("37") { mock_plan }
        mock_plan.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :plan => {'these' => 'params'}
      end

      it "assigns the requested plan as @plan" do
        Plan.stub(:find) { mock_plan(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:plan).should be(mock_plan)
      end

      it "redirects to the plan" do
        Plan.stub(:find) { mock_plan(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(plan_url(mock_plan))
      end
    end

    describe "with invalid params" do
      it "assigns the plan as @plan" do
        Plan.stub(:find) { mock_plan(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:plan).should be(mock_plan)
      end

      it "re-renders the 'edit' template" do
        Plan.stub(:find) { mock_plan(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested plan" do
      Plan.should_receive(:find).with("37") { mock_plan }
      mock_plan.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the plans list" do
      Plan.stub(:find) { mock_plan }
      delete :destroy, :id => "1"
      response.should redirect_to(plans_url)
    end
  end

end
