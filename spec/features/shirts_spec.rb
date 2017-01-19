require "rails_helper"

RSpec.describe 'shirts', :type => :feature do
  let(:password) { 'asdfasdf' }
  let(:admin) { create :admin, :password => password }

  it 'admin can manage shirts' do
    visit new_user_session_path(year: admin.year)
    fill_in 'Email', with: admin.email
    fill_in 'Password', with: password
    click_button 'Sign in'
    click_link 'Shirts'
    expect(page).to have_selector 'h2', :text => 'Shirts'

    click_button 'Add Shirt'
    expect(page).to have_selector 'h2', :text => 'New Shirt'
    fill_in 'Name', with: 'Radioactive Green'
    fill_in 'Description', with: 'Lorem ipsum dolor sit amet'
    fill_in 'Hex triplet', with: '00ff00'
    click_button 'Save'
    expect(page).to have_selector 'h2', :text => 'Shirts'

    click_link 'Radioactive Green'
    fill_in 'Name', with: 'Mutagen Green'
    click_button 'Save'
    expect(page).to have_content 'Mutagen Green'

    click_link 'Delete'
    expect(page).to have_selector 'h2', :text => 'Shirts'
    expect(page).not_to have_content 'Mutagen Green'
  end
end
