FactoryBot.define do
  factory :bulk_discount do
    merchant { nil }
    percentage_discount { 1 }
    quantity_treshold { 1 }
  end
end
