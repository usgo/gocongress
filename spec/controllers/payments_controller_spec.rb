require "spec_helper"

describe PaymentsController do
  render_views

  describe '#new' do
    it 'requires authentication' do
      get :new
      response.should be_forbidden
    end

    it 'assings a sim_transaction with a cust_id' do
      u = create :user
      sign_in(u)
      get :new
      response.should be_success
      assigns(:sim_transaction).should_not be_nil
      assigns(:sim_transaction).fields[:cust_id].should == u.id
    end
  end

  describe '#relay_response' do
    it 'succeeds' do
      post :relay_response
      response.should be_success
      assigns(:sim_response).should_not be_nil
    end

    context 'when the sim response is successful' do
      before do
        AuthorizeNet::SIM::Response.any_instance.stub(:success?) { true }
      end

      it 'includes url of happy receipt when saving the transaction succeeds' do
        Transaction.stub(:create_from_authnet_sim_response) { true }
        post :relay_response
        response.should be_success
        expected_url = payments_receipt_url(
          :transaction_saved => true,
          :only_path => false)
        response.body.should include expected_url
      end

      it 'includes url of sad receipt when saving the transaction fails' do
        Transaction.stub(:create_from_authnet_sim_response) do
          raise ActiveRecord::RecordNotFound
        end
        post :relay_response
        response.should be_success
        expected_url = payments_receipt_url(
          :transaction_saved => false,
          :only_path => false)
        response.body.should include expected_url
      end
    end

    it 'renders error message when declined' do
      post :relay_response, {:x_response_code => 2}
      response.should be_success
      response.body.should include('Sorry, your card was declined.')
    end

    it 'renders error message when sim response is error' do
      post :relay_response, {:x_response_code => 3}
      response.should be_success
      response.body.should include('Sorry, there was an error')
    end

    it 'renders error message when approved, but hashing fails' do
      post :relay_response, {:x_response_code => 1}
      response.should be_success
      response.body.should include('unable to authenticate the response')
    end
  end
end
