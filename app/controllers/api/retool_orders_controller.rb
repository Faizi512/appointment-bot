module Api
  class RetoolOrdersController < ApplicationController
    protect_from_forgery except: :update
    def index
      @orders = RetoolOrder.all
    end

    def update
      puts "############"
      puts "params #{params}"
      if params.present?
        params[:Key1].each do |order|
          RetoolOrder.find_or_create_by(order_id: order[:order_id]).update(
            order_number: order[:order_number],
            shipment_number: order[:shipment_number],
            product_name: order[:product_name],
            order_state: order[:order_state],
            shipment_state: order[:shipment_state],
            payment_state: order[:payment_state],
            completed_at: order[:completed_at],
            store_location_id: order[:stock_location_id],
            eta_date: order[:"Calculated Column 2"],
            contracted_date: order[:"Calculated Column 1"])
        end
      end
      render json: "success".to_json, status: :ok
    end

  end
end