require 'rails_helper'
describe 'Admin Merchant index page' do
  before :each do
    @merchants = []
    10.times {@merchants << create(:merchant)}
  end

  it 'Should list all merchant names' do
    visit '/admin/merchants'

    expect(page).to have_content(@merchants[0].name)
    expect(page).to have_content(@merchants[1].name)
    expect(page).to have_content(@merchants[2].name)
    expect(page).to have_content(@merchants[3].name)
    expect(page).to have_content(@merchants[4].name)
    expect(page).to have_content(@merchants[5].name)
  end

  it 'should have update active button' do
    visit '/admin/merchants'
    within("div#merchant-#{@merchants[0].id}") do
      click_button "Deactivate"
    end

    expect(current_path).to eq(admin_merchants_path)
    expect(page).to have_content("#{@merchants[0].name} is Inactive")
  end
end