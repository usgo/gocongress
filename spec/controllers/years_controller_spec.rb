require "spec_helper"

describe YearsController do
  let(:year) { Year.find_by_year(2013) }

  context 'as a user' do
    before do
      sign_in create :user
    end

    it 'denies edit' do
      get :edit, year: year.year
      should_deny_access(response)
    end

    it 'denies update' do
      put :update, year: year.year
      should_deny_access(response)
    end
  end

  context 'as an admin' do
    before do
      sign_in create :admin
    end

    describe '#update' do
      it 'can update the city' do
        new_city = 'Terminator'
        expect {
          put :update, {year: year.year, year_record: {city: new_city}}
        }.to_not raise_exception
        year.reload.city.should == new_city
      end

      it 'cannot update the year attribute' do
        expect {
          put :update, {year: year.year, year_record: {year: 2312}}
        }.to raise_exception(ActiveModel::MassAssignmentSecurity::Error)
      end
    end
  end

  def should_deny_access response
    response.should be_forbidden
    response.should render_template :access_denied
  end
end
