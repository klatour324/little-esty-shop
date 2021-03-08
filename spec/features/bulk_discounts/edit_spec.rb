require 'rails_helper'

RSpec.describe "Bulk Discount Edit Page" do
  before :each do
    @merchant1 = create(:merchant)
    @merchant1_bulk_discount1 = create(:bulk_discount, merchant_id: @merchant1.id, quantity_treshold: 2, percentage_discount: 50)
    @merchant1_bulk_discount2 = create(:bulk_discount, merchant_id: @merchant1.id, quantity_treshold: 100, percentage_discount: 30)
    @merchant1_bulk_discount3 = create(:bulk_discount, merchant_id: @merchant1.id, quantity_treshold: 50, percentage_discount: 15)
    @merchant2 = create(:merchant)
    @merchant2_bulk_discount1 = create(:bulk_discount, merchant_id: @merchant2.id, quantity_treshold: 10, percentage_discount: 10)
  end
  describe "As a merchant" do
    describe "I visit my bulk discount show page" do
      it "I see a link to edit the bulk discount and by clicking I am taken to edit page" do
        visit "/merchant/#{@merchant1.id}/bulk_discounts/#{@merchant1_bulk_discount1.id}"
          within "#bulk-discount-info-edit" do
            expect(page).to have_link("Edit Bulk Discount")
            click_on("Edit Bulk Discount")
            expect(current_path).to eq("/merchant/#{@merchant1.id}/bulk_discounts/#{@merchant1_bulk_discount1.id}/edit")
          end
      end
    end
    describe "In the bulk discount edit page" do
      it "I can see the current attributes populated" do
        visit "/merchant/#{@merchant1.id}/bulk_discounts/#{@merchant1_bulk_discount1.id}"
          click_on("Edit Bulk Discount")
            within ".bulk-discount-form" do
              expect(page).to have_field('bulk_discount[quantity_treshold]', with: "#{@merchant1_bulk_discount1.quantity_treshold}")
              expect(page).to have_field('bulk_discount[percentage_discount]', with: "#{@merchant1_bulk_discount1.percentage_discount}")
              expect(page).to_not have_field('bulk_discount[quantity_treshold]', with: "#{@merchant1_bulk_discount2.quantity_treshold}")
              expect(page).to_not have_field('bulk_discount[percentage_discount]', with: "#{@merchant1_bulk_discount2.percentage_discount}")
              expect(page).to_not have_field('bulk_discount[quantity_treshold]', with: "#{@merchant1_bulk_discount3.quantity_treshold}")
              expect(page).to_not have_field('bulk_discount[percentage_discount]', with: "#{@merchant1_bulk_discount3.percentage_discount}")
            end
      end
      it "I change all of the information, click submit and I can see the changes" do
        visit "/merchant/#{@merchant1.id}/bulk_discounts/#{@merchant1_bulk_discount1.id}"
          click_on("Edit Bulk Discount")
            within ".bulk-discount-form" do
              fill_in "bulk_discount[quantity_treshold]", with: 99
              fill_in "bulk_discount[percentage_discount]", with: 55
              click_button('Update')
              expect(current_path).to eq("/merchant/#{@merchant1.id}/bulk_discounts/#{@merchant1_bulk_discount1.id}")
            end
            within "#bulk-discount-information" do
              expect(page).to have_content(99)
              expect(page).to have_content(55)
            end
      end
      it "I change any of the information, click submit and I can see the changes" do
        visit "/merchant/#{@merchant1.id}/bulk_discounts/#{@merchant1_bulk_discount1.id}"
          click_on("Edit Bulk Discount")
            within ".bulk-discount-form" do
              fill_in "bulk_discount[quantity_treshold]", with: 99
              click_button('Update')
              expect(current_path).to eq("/merchant/#{@merchant1.id}/bulk_discounts/#{@merchant1_bulk_discount1.id}")
            end
            within "#bulk-discount-information" do
              expect(page).to have_content(99)
              expect(page).to_not have_content(55)
            end
      end
    end
  end
end