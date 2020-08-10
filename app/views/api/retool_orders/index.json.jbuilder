json.array!(@orders) do |order|
  json.order_id order.order_id
  json.eta_date order.eta_date#.strftime('%d-%m-%Y')
  json.contracted_date order.contracted_date#.strftime('%d-%m-%Y')
end