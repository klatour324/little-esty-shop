require 'rails_helper'

RSpec.describe BulkDiscount, type: :model do
  describe "relationships" do
    it { should belong_to :merchant}
    it {should have_many(:items).through(:merchant)}
    it {should have_many(:invoice_items).through(:items)}
  end

  describe "validations" do
    it { should validate_presence_of :quantity_treshold }
    it { should validate_presence_of :percentage_discount}
  end
end
