class BulkDiscount < ApplicationRecord
  belongs_to :merchant

  validates :quantity_treshold, :percentage_discount, presence: true
end
