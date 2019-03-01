require "rails_helper"

RSpec.describe 'registration form', :type => :feature do
  let(:password) { 'asdfasdf' }
  let(:user) { create :user, :password => password }

  before do
    visit new_user_session_path(year: user.year)
    fill_in 'Email', with: user.email
    fill_in 'Password', with: password
    click_button 'Sign in'
    expect(page).to have_content('My Account')
    visit new_registration_path(year: user.year, user_id: user.id, type: 'adult')
    expect(page).to have_content('First Attendee')
    expect(page).to have_selector('form')
  end

  context 'new' do
    it 'saves a new attendee' do
      fill_in 'Given Name', with: 'Minnie'
      fill_in 'Family Name', with: 'Mouse'
      choose 'registration_gender_f'
      select 1930, from: 'registration_birth_date_1i'
      select 'January', from: 'registration_birth_date_2i'
      select 1, from: 'registration_birth_date_3i'
      select 'Adult Small', from: 'registration_tshirt_size'
      select '10 kyu', from: 'registration_rank'
      choose 'registration_receive_sms_true'
      fill_in "Phone at Congress", with: "16122035280"
      fill_in 'Email', with: 'minnie.mouse@example.com'
      select 'Aland Islands', from: 'registration_country'
      fill_in 'Emergency Contact Name', with: 'Jenny'
      fill_in 'Emergency Contact Phone', with: '867-5309'
      choose 'registration_will_play_in_us_open_true'
      click_button 'Continue'
      expect(page).to have_content 'Attendee added'
      expect(page).to have_content 'What next?'
    end

    it 'shows errors when form is invalid' do
      fill_in 'Given Name', with: 'Minnie'
      click_button 'Continue'
      expect(page).to have_selector '#error_explanation'
      expect(page).to have_content "Family name can't be blank"
    end
    it 'shows errors when receive_sms_true and local phone is missing' do
      fill_in 'Given Name', with: 'Minnie'
      fill_in 'Family Name', with: 'Mouse'
      choose 'registration_gender_f'
      select 1930, from: 'registration_birth_date_1i'
      select 'January', from: 'registration_birth_date_2i'
      select 1, from: 'registration_birth_date_3i'
      select 'Adult Small', from: 'registration_tshirt_size'
      select '10 kyu', from: 'registration_rank'
      choose 'registration_receive_sms_true'

      fill_in 'Email', with: 'minnie.mouse@example.com'
      select 'Aland Islands', from: 'registration_country'
      fill_in 'Emergency Contact Name', with: 'Jenny'
      fill_in 'Emergency Contact Phone', with: '867-5309'
      choose 'registration_will_play_in_us_open_true'
      click_button 'Continue'
      expect(page).to have_selector '#error_explanation'
      expect(page).to have_content "Local Phone can't be blank"
    end
  end

  context 'edit' do
    let(:a) { create :attendee, user: user }
    before do
      visit edit_registration_path(year: a.year, id: a.id, type: 'adult')
      expect(page).to have_selector 'form#edit_registration_' + a.id.to_s
    end

    it 'updates an attendee' do
      fill_in 'Family Name', with: 'Rothchild'
      click_button 'Continue'
      expect(a.reload.family_name).to eq('Rothchild')
    end

    it 'shows errors when form is invalid' do
      fill_in 'Family Name', with: ''
      click_button 'Continue'
      expect(page).to have_selector '#error_explanation'
      expect(page).to have_content "Family name can't be blank"
    end
  end
end
