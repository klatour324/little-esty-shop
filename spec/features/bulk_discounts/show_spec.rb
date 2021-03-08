require 'rails_helper'

RSpec.describe "Bulk Discount Show Page" do
  before :each do
    @merchant1 = create(:merchant)
    @merchant1_bulk_discount1 = create(:bulk_discount, merchant_id: @merchant1.id, quantity_treshold: 2, percentage_discount: 50)
    @merchant1_bulk_discount2 = create(:bulk_discount, merchant_id: @merchant1.id, quantity_treshold: 100, percentage_discount: 30)
    @merchant1_bulk_discount3 = create(:bulk_discount, merchant_id: @merchant1.id, quantity_treshold: 50, percentage_discount: 15)
    @merchant2 = create(:merchant)
    @merchant2_bulk_discount1 = create(:bulk_discount, merchant_id: @merchant2.id, quantity_treshold: 10, percentage_discount: 10)
  end
  describe "As a merchant" do
    describe "When I visit my bulk discount show page" do
      it "I see the bulk discount's quantity threshold and percentage discount" do
        visit "/merchant/#{@merchant1.id}/bulk_discounts/#{@merchant1_bulk_discount1.id}"
          within "#bulk-discount-information" do
            expect(page).to have_content(@merchant1_bulk_discount1.quantity_treshold)
            expect(page).to have_content(@merchant1_bulk_discount1.percentage_discount)
          end
      end
      it "I do not see another bulk dicount information for same merchant" do
        visit "/merchant/#{@merchant1.id}/bulk_discounts/#{@merchant1_bulk_discount1.id}"
          within "#bulk-discount-information" do
            expect(page).to_not have_content(@merchant1_bulk_discount2.quantity_treshold)
            expect(page).to_not have_content(@merchant1_bulk_discount2.percentage_discount)
          end
      end
      it "I do not see another merchant bulk discount info" do
        visit "/merchant/#{@merchant1.id}/bulk_discounts/#{@merchant1_bulk_discount1.id}"
          within "#bulk-discount-information" do
            expect(page).to_not have_content(@merchant2_bulk_discount1.quantity_treshold)
            expect(page).to_not have_content(@merchant2_bulk_discount1.percentage_discount)
          end
      end
    end
  end
end