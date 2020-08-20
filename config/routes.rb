Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
  	get "/retool_orders" => "retool_orders#index"
  	patch "/retool_orders" => "retool_orders#update"
  	patch "/retool_orders/update_record" => "retool_orders#update_record"
  end
end
