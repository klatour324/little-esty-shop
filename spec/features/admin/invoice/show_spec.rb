require 'rails_helper'
describe 'Admin Invoice Show Page' do
  before :each do
    @customer = create(:customer)
    @merchant = create(:merchant)
    @invoice = create(:invoice, customer_id: @customer.id)
    @item1 = create(:item, merchant_id: @merchant.id)
    @item2 = create(:item, merchant_id: @merchant.id)
    @invoice_item1 = create(:invoice_item, invoice_id: @invoice.id, item_id: @item1.id)
    @savy_merchant = Merchant.create(name: "Save Lotz")
    @discount1 = @savy_merchant.bulk_discounts.create(quantity_treshold: 500, percentage_discount: 25)
    @discount2 = @savy_merchant.bulk_discounts.create(quantity_treshold: 400, percentage_discount: 20)
    @discount3 = @savy_merchant.bulk_discounts.create(quantity_treshold: 1200, percentage_discount: 50)
    @discount4 = @savy_merchant.bulk_discounts.create(quantity_treshold: 150, percentage_discount: 5)
    @item_lot = @savy_merchant.items.create(name: "USB Chargers", description: "Latest Model USB", unit_price: 15.99)
    @network_cables = @savy_merchant.items.create(name: "Network Cables", description: "2ft Long High Quality Cable", unit_price: 20.99)
    @john = Customer.create!(first_name: "John", last_name: "Kelley")
    @discount_invoice = @john.invoices.create(status: 1)
    @johns_invoice_item = InvoiceItem.create!(invoice_id: @discount_invoice.id,
                                       item_id: @item_lot.id, quantity: 500,
                                       unit_price: 15.99, status: 2)
    @johns_invoice_item2 = InvoiceItem.create!(invoice_id: @discount_invoice.id,
                                          item_id: @network_cables.id, quantity: 200,
                                          unit_price: 20.99, status: 2)
    @johns_invoice_item3 = InvoiceItem.create!(invoice_id: @discount_invoice.id,
                                          item_id: @item2.id, quantity: 5,
                                          unit_price: 100, status: 2)
  end

  it 'Sees Invoice and attributes' do
    visit admin_invoice_path(@invoice)

    expect(page).to have_content(@invoice.id)
    expect(page).to have_content(@invoice.status)
    expect(page).to have_content(@invoice.created_at.strftime("%A, %B %d, %Y"))
  end

  it "Sees Customer Information" do
    visit admin_invoice_path(@invoice)

    expect(page).to have_content(@customer.first_name)
    expect(page).to have_content(@customer.last_name)
  end

  it "Sees All Items on Invoice" do
    visit admin_invoice_path(@invoice)

    expect(page).to have_content(@item1.name)
    expect(page).to_not have_content(@item2.name)
    expect(page).to have_content(@invoice_item1.quantity)
    expect(page).to have_content(@invoice_item1.unit_price)
    expect(page).to have_content(@invoice_item1.status)
  end

  it "Sees an Invoice's Total Revenue" do
    visit admin_invoice_path(@invoice)
    expect(page).to have_content(@invoice.total_revenue)
  end

  it 'sees select feild for invoice status' do
    visit admin_invoice_path(@invoice)
    select('completed', from: 'status')
    expect(page).to have_button("Submit")
    click_button('Submit')
    expect(page).to have_content(@invoice.status)
    expect(current_path).to eq(admin_invoice_path(@invoice))
    expect(page).to have_content(@invoice.id)
  end

  it "I see that the total revenue includes bulk discounts in the calculation" do
    visit admin_invoice_path(@discount_invoice)
    within "#invoice-total-revenue" do
      expect(page).to have_content(@discount_invoice.total_revenue_with_discount)
      expect(page).to_not have_content(@invoice.total_revenue_with_discount)
    end
  end
end