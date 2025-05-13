json.extract! transaction, :id, :description, :amount, :category, :created_at, :updated_at
json.url transaction_url(transaction, format: :json)
