require "spec_helper"

describe PaymentsController, :type => :controller do
  render_views

  describe '#new' do
    it 'requires a user_id' do
      get :new
      expect(response).to redirect_to new_user_session_url(:protocol => 'http')
    end

    it 'assings a sim_transaction with a cust_id' do
      u = create :user
      sign_in(u)
      get :new, user_id: u.id
      expect(response).to be_success
      expect(assigns(:sim_transaction)).not_to be_nil
      expect(assigns(:sim_transaction).fields[:cust_id]).to eq(u.id)
    end
  end

  describe '#relay_response' do
    it 'succeeds' do
      post :relay_response
      expect(response).to be_success
      expect(assigns(:sim_response)).not_to be_nil
    end

    context 'when the sim response is successful' do
      before do
        allow_any_instance_of(AuthorizeNet::SIM::Response).to receive(:success?) { true }
      end

      it 'includes url of happy receipt when saving the transaction succeeds' do
        allow(Transaction).to receive(:create_from_authnet_sim_response) { true }
        post :relay_response
        expect(response).to be_success
        expected_url = payments_receipt_url(
          :protocol => 'https',
          :transaction_saved => true,
          :only_path => false)
        expect(response.body).to include expected_url
      end

      it 'includes url of sad receipt when saving the transaction fails' do
        msg = "sadness"
        allow(Transaction).to receive(:create_from_authnet_sim_response) do
          raise ActiveRecord::RecordNotFound, msg
        end
        post :relay_response
        expect(response).to be_success
        expected_url = payments_receipt_url(
          :protocol => 'https',
          :transaction_saved => false,
          :error_msg => msg,
          :only_path => false)
        expect(response.body).to include expected_url
      end
    end

    it 'renders error message when declined' do
      post :relay_response, {:x_response_code => 2}
      expect(response).to be_success
      expect(response.body).to include('your card was declined.')
    end

    it 'renders error message when sim response is error' do
      post :relay_response, {:x_response_code => 3}
      expect(response).to be_success
      expect(response.body).to include('there was an error')
    end

    it 'renders error message when approved, but hashing fails' do
      post :relay_response, {:x_response_code => 1}
      expect(response).to be_success
      expect(response.body).to include('unable to authenticate the response')
    end
  end
end
