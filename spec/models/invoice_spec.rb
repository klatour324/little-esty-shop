require 'rails_helper'

RSpec.describe Invoice, type: :model do
  before :each do
    @john = Customer.create!(first_name: "John", last_name: "Kelley")
    @customer1 = Customer.create(first_name: "Joe",
                                 last_name: "Smith")
    @invoice1 = @customer1.invoices.create(status: 0)
    @invoice2 = @customer1.invoices.create(status: 1)
    @invoice3 = @customer1.invoices.create(status: 2)
    @invoice4 = @customer1.invoices.create(status: 0)
    @discount_invoice = @john.invoices.create(status: 1)

    @savy_merchant = Merchant.create(name: "Save Lotz")
    @merchant = Merchant.create(name: "John's Jewelry")

    @discount1 = @savy_merchant.bulk_discounts.create(quantity_treshold: 500, percentage_discount: 25)
    @discount2 = @savy_merchant.bulk_discounts.create(quantity_treshold: 400, percentage_discount: 20)
    @discount3 = @savy_merchant.bulk_discounts.create(quantity_treshold: 1200, percentage_discount: 50)
    @discount4 = @savy_merchant.bulk_discounts.create(quantity_treshold: 150, percentage_discount: 5)

    @item_lot = @savy_merchant.items.create(name: "USB Chargers", description: "Latest Model USB", unit_price: 15.99)
    @network_cables = @savy_merchant.items.create(name: "Network Cables", description: "2ft Long High Quality Cable", unit_price: 20.99)

    @item1 = @merchant.items.create(name: "Gold Ring", description: "14K Wedding Band",
                                    unit_price: 599.95)
    @item2 = @merchant.items.create(name: "Diamond Ring", description: "Shiny",
                                    unit_price: 1000.00)
    @item3 = @merchant.items.create(name: "Silver Ring", description: "Plain",
                                    unit_price: 350.00)
    @item4 = @merchant.items.create(name: "Mood Ring", description: "Strong mood vibes",
                                    unit_price: 100.00)

    @invoice_item1 = InvoiceItem.create!(invoice_id: @invoice1.id,
                                         item_id: @item1.id, quantity: 500,
                                         unit_price: 599.95, status: 0)
    @invoice_item2 = InvoiceItem.create!(invoice_id: @invoice2.id,
                                         item_id: @item2.id, quantity: 200,
                                         unit_price: 1000.00, status: 0)
    @invoice_item3 = InvoiceItem.create!(invoice_id: @invoice3.id,
                                         item_id: @item1.id, quantity: 100,
                                         unit_price: 350.00, status: 0)
    @invoice_item4 = InvoiceItem.create!(invoice_id: @invoice4.id,
                                         item_id: @item4.id, quantity: 400,
                                         unit_price: 100.00, status: 0)
    @johns_invoice_item = InvoiceItem.create!(invoice_id: @discount_invoice.id,
                                          item_id: @item_lot.id, quantity: 500,
                                          unit_price: 15.99, status: 2)
    @johns_invoice_item2 = InvoiceItem.create!(invoice_id: @discount_invoice.id,
                                          item_id: @network_cables.id, quantity: 200,
                                          unit_price: 20.99, status: 2)
    @johns_invoice_item3 = InvoiceItem.create!(invoice_id: @discount_invoice.id,
                                          item_id: @item4.id, quantity: 5,
                                          unit_price: 100, status: 2)

  end

  describe "relationships" do
    it {should belong_to :customer}
    it {should have_many :invoice_items}
    it {should have_many(:items).through(:invoice_items)}
    it {should have_many(:merchants).through(:items)}
    it {should have_many(:bulk_discounts).through(:merchants)}
  end

  describe "different statuses" do
    it 'can display in progress' do
      expect(@invoice1.status).to eq("in progress")
      expect(@invoice1.status).to_not eq("cancelled")
      expect(@invoice1.status).to_not eq("completed")
    end

    it 'can display completed' do
      expect(@invoice2.status).to eq("completed")
      expect(@invoice2.status).to_not eq("cancelled")
      expect(@invoice2.status).to_not eq("in progress")
    end

    it 'can display cancelled' do
      expect(@invoice3.status).to eq("cancelled")
      expect(@invoice3.status).to_not eq("completed")
      expect(@invoice3.status).to_not eq("in progress")
    end
  end

  describe "instance methods" do
    describe "#date_format" do
      it "returns the created_at attribute in string formatted properties ex Monday, July 18, 2019" do
        invoice = @customer1.invoices.create(status: 0,created_at: Time.new(2019, 07, 18))
        expect(invoice.date_format).to eq("Thursday, July 18, 2019")
      end
    end
    describe "#status_format" do
      it "returns the status with each first letter capitalized for every word" do
        expect(@invoice1.status_format).to eq("In Progress")
        expect(@invoice2.status_format).to eq("Completed")
        expect(@invoice3.status_format).to eq("Cancelled")
      end
    end
    describe "#total_revenue" do
      it "returns total sum of the invoice_item quanity * invoice_item unit_price " do
        expect(@invoice1.total_revenue.round(2)).to eq(299975.00)
      end
    end

    describe "#discount_total" do
      it "returns joins table showing the highest bulk_discount applied and calculates the discount amount as revenue_discount " do
        expect(@discount_invoice.discount_total.length).to eq(4)
        expect(@discount_invoice.discount_total.first.bulk_discount_id).to eq(@discount4.id)
      end
      it "can only apply to highest revenue discount" do
        expect(@discount_invoice.discount_total.first.revenue_discount).to be > (@discount_invoice.discount_total.second.revenue_discount)
      end
      it "can have include different items from same merchant" do
        expect(@discount_invoice.discount_total.first.item_id).to eq(@item_lot.id)
        expect(@discount_invoice.discount_total.second.item_id).to eq(@network_cables.id)
      end
    end
    describe "#total_revenue_with_discount" do
      it "returns the adjusted revenue for an invoice with discounts" do
        expect(@discount_invoice.total_revenue_with_discount).to be < (@discount_invoice.total_revenue)
        expect(@discount_invoice.total_revenue_with_discount).to eq(10254.4)
      end
      it "returns the same amount as revenue since there were no discounts in the invoice" do
        expect(@invoice1.total_revenue_with_discount).to eq(@invoice1.total_revenue)
      end
    end
    describe "class methods" do
      describe "::not_shipped" do
        it "returns the invoices that have not been shipped and orders them from oldest to newest" do
          expect(@customer1.invoices.not_shipped[0]).to eq(@invoice1)
          expect(@customer1.invoices.not_shipped[-1]).to eq(@invoice4)
          expect(@customer1.invoices.not_shipped).to eq([@invoice1, @invoice2, @invoice3, @invoice4])
        end
      end
    end
  end
end
