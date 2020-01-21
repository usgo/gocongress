require "rails_helper"

RSpec.describe 'tournaments', :type => :feature do
  let(:password) { 'asdfasdf' }
  let(:admin) { create :admin, :password => password }
  let!(:tournament1) { create :tournament }
  let!(:tournament2) { create :tournament }

  before(:each) do
    visit new_user_session_path(year: admin.year)
    fill_in 'Email', with: admin.email
    fill_in 'Password', with: password
    click_button 'Sign in'
  end

  it 'saves orders' do
    visit tournaments_path(year: admin.year)
    expect(page).to have_text 'Order'
    fill_in "ordinals[#{tournament1.id}]", with: 2
    fill_in "ordinals[#{tournament2.id}]", with: 3
    click_button 'Update Order'
    expect(page).to have_text 'Order updated'

    tournament1.reload
    tournament2.reload
    expect(tournament1.ordinal).to eq(2)
    expect(tournament2.ordinal).to eq(3)
  end
end
