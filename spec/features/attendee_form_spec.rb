require 'spec_helper'

describe 'attendee form' do
  let(:user) { create :user, :password => 'asdf' }

  before do
    visit new_user_session_path(year: user.year)
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'asdf'
    click_button 'Sign in'
    expect(page).to have_content('First Attendee')
    page.should have_selector('form')
  end

  context 'new' do
    it 'saves a new attendee' do
      fill_in 'Given Name', with: 'Minnie'
      fill_in 'Family Name', with: 'Mouse'
      choose 'attendee_gender_f'
      select 1930, from: 'attendee_birth_date_1i'
      select 'January', from: 'attendee_birth_date_2i'
      select 1, from: 'attendee_birth_date_3i'
      select 'Adult Small', from: 'attendee_tshirt_size'
      select '10 kyu', from: 'attendee_rank'
      select 'Aland Islands', from: 'attendee_country'
      click_button 'Continue'
      page.should have_content 'Attendee added'
      page.should have_content 'What next?'
    end

    it 'shows errors when form is invalid' do
      fill_in 'Given Name', with: 'Minnie'
      click_button 'Continue'
      page.should have_selector '#error_explanation'
      page.should have_content "Family Name can't be blank"
    end
  end

  context 'edit' do
    let(:a) { create :attendee, user: user }
    before do
      visit edit_attendee_path(year: a.year, id: a.id)
      page.should have_selector 'form#edit_attendee_' + a.id.to_s
    end

    it 'updates an attendee' do
      fill_in 'Family Name', with: 'Rothchild'
      click_button 'Continue'
      a.reload.family_name.should == 'Rothchild'
    end

    it 'shows errors when form is invalid' do
      fill_in 'Family Name', with: ''
      click_button 'Continue'
      page.should have_selector '#error_explanation'
      page.should have_content "Family Name can't be blank"
    end
  end
end
