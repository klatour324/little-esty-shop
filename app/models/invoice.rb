class Invoice < ApplicationRecord
  belongs_to :customer
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items
  has_many :bulk_discounts, through: :merchants
  enum status: {"in progress" => 0, completed: 1, cancelled: 2}

  def total_revenue
    invoice_items.calculate_revenue
  end

  def self.not_shipped
    joins(:invoice_items)
    .where("invoice_items.status = 0 OR invoice_items.status = 1")
    .distinct
    .order(created_at: :asc)
  end

  def date_format
    created_at.strftime("%A, %B %d, %Y")
  end

  def status_format
    status.titleize
  end

  def discount_total
     invoice_items.joins(:bulk_discounts).where("invoice_items.quantity >= bulk_discounts.quantity_treshold")
     .select("(invoice_items.unit_price * invoice_items.quantity)/bulk_discounts.percentage_discount as revenue_discount, invoice_items.*, bulk_discounts.id as bulk_discount_id")
     .order(revenue_discount: :desc)
  end

  def total_revenue_with_discount
    total_revenue - discount_total.uniq.sum(&:revenue_discount)
  end
end
