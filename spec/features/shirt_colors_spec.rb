require 'spec_helper'

describe 'shirt colors' do
  let(:password) { 'asdfasdf' }
  let(:admin) { create :admin, :password => password }

  it 'admin can manage colors' do
    visit new_user_session_path(year: admin.year)
    fill_in 'Email', with: admin.email
    fill_in 'Password', with: password
    click_button 'Sign in'
    click_link 'Shirts'
    page.should have_selector 'h2', :text => 'Shirt Colors'

    click_button 'Add Color'
    page.should have_selector 'h2', :text => 'New Color'
    fill_in 'Name', with: 'Radioactive Green'
    fill_in 'Hex triplet', with: '00ff00'
    click_button 'Save'
    page.should have_selector 'h2', :text => 'Shirt Colors'

    click_link 'Radioactive Green'
    fill_in 'Name', with: 'Mutagen Green'
    click_button 'Save'
    page.should have_content 'Mutagen Green'

    click_link 'Delete'
    page.should have_selector 'h2', :text => 'Shirt Colors'
    page.should_not have_content 'Mutagen Green'
  end
end
