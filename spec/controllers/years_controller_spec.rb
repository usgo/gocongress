require "rails_helper"

RSpec.describe YearsController, :type => :controller do
  let(:y) { 2013 }
  let(:year) { Year.find_by_year(y) }

  context 'as a user' do
    before do
      sign_in create :user, year: y
    end

    it 'denies edit' do
      get :edit, params: { year: year.year }
      should_deny_access(response)
    end

    it 'denies update' do
      patch :update, params: { year: year.year }
      should_deny_access(response)
    end
  end

  context 'as an admin' do
    let(:new_city) { 'Terminator' }

    context 'from same year' do
      before do
        sign_in create :admin, year: y
      end

      describe '#update' do
        it 'can update the city' do
          expect {
            patch :update, params: { year: year.year, year_record: { city: new_city } }
          }.to_not raise_exception
          expect(year.reload.city).to eq(new_city)
        end

        it 'cannot update the year attribute' do
          expect {
            patch :update, params: { year: year.year, year_record: { year: 2312 } }
          }.to raise_exception(ActionController::UnpermittedParameters)
        end
      end
    end

    context 'from different year' do
      before do
        sign_in create :admin, year: y + 1
      end

      describe '#update' do
        it 'is forbidden' do
          expect {
            patch :update, params: { year: year.year, year_record: { city: new_city } }
          }.to_not change { year.reload.city }
          expect(response).to be_forbidden
        end
      end
    end
  end

  def should_deny_access response
    expect(response).to be_forbidden
    expect(response).to render_template :access_denied
  end
end
