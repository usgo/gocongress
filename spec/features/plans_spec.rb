require "rails_helper"

RSpec.describe 'plans', :type => :feature do
  let(:password) { 'asdfasdf' }
  let(:admin) { create :admin, :password => password }

  it 'adds ability for admins to save new plans while registration phase is not closed' do
    visit new_user_session_path(year: admin.year)
    fill_in 'Email', with: admin.email
    fill_in 'Password', with: password
    click_button 'Sign in'
    click_link 'Settings'
    expect(page).to have_selector 'h2', :text => 'Settings'
    select '2. Open', from: 'year_record_registration_phase'
    click_button 'Submit'
    expect(page).to have_content 'Settings updated'
    visit new_plan_path(year: admin.year)
    expect(page).to have_button('Save')
  end
end
