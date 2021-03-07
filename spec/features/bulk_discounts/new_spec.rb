require 'rails_helper'

RSpec.describe "Merchant Bulk Discount New Page" do
  before :each do
    @merchant1 = create(:merchant)
  end
  describe "As a merchant when I visit my bulk discounts index" do
    describe "Then I see a link to create a new discount" do
      it "by cliking this link I am taken to a new page where I see a form to add a new bulk discount" do
        visit "/merchant/#{@merchant1.id}/bulk_discounts"
          within "#new-bulk-discount" do
            expect(page).to have_link("Create Bulk Discount")
            click_on("Create Bulk Discount")
            expect(current_path).to eq("/merchant/#{@merchant1.id}/bulk_discounts/new")
          end
      end
    end
  end
  describe "As a merchant I can create a new record" do
    describe "When I visit a merchant new page for bulk discount" do
      it "there is a form I can fill out with valid data and I can see the record created" do
        visit "/merchant/#{@merchant1.id}/bulk_discounts/new"
          within ".bulk-discount-form" do
            fill_in "bulk_discount[quantity_treshold]", with: 20
            fill_in "bulk_discount[percentage_discount]", with: 10
            click_button("Submit")
          end
          expect(current_path).to eq("/merchant/#{@merchant1.id}/bulk_discounts")
          within "#all-merchant-bulk-discounts" do
            expect(page).to have_content(10)
            expect(page).to have_content(20)
          end
      end
      it "can not create records with empty fields" do
        visit "/merchant/#{@merchant1.id}/bulk_discounts/new"
          within ".bulk-discount-form" do
            click_button("Submit")
          end
          expect(page).to have_content("Fields Missing: Fill in all fields")
          expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant1))
          within ".bulk-discount-form" do
            fill_in "bulk_discount[quantity_treshold]", with: 30
            click_button("Submit")
          end
          expect(page).to have_content("Fields Missing: Fill in all fields")
          expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant1))
          within ".bulk-discount-form" do
            fill_in "bulk_discount[percentage_discount]", with: 5
            click_button("Submit")
          end
          expect(page).to have_content("Fields Missing: Fill in all fields")
          expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant1))
      end
    end
  end
end