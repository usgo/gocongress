require "spec_helper"

describe YearsController do
  context 'as an admin' do
    before do
      sign_in create :admin
    end

    describe '#update' do
      let(:year) { Year.find_by_year(2013) }

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
end
