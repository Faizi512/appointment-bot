module Api
  class RetoolOrdersController < ApplicationController
    protect_from_forgery except: :update
    def index
      @orders = RetoolOrder.all
    end

    def update
      if params.present?
        process_oder_id = []
        params[:Key1].each do |order|
        data1 = {order_id: order[:order_id]}
          data1 = {order_id: order[:order_id],
              order_number: order[:order_number],
              shipment_number: order[:shipment_number],
              email: order[:email],
              product_name: order[:product_name],
              order_state: order[:order_state],
              shipment_state: order[:shipment_state],
              payment_state: order[:payment_state],
              completed_at: order[:completed_at],
              store_location_id: order[:store_location_id],
              stock_location_name: order[:stock_location_name]}
          data2 = {eta_date: order[:estimated_eta],
              contracted_date: order[:contracted_date]}
          if order[:estimated_eta].present? || order[:contracted_date].present?    
            data1.merge!(data2)
          end
          data3 = {product_eta: order[:brand_eta]}
          if order[:product_eta].present?
            data3[:product_eta] = order[:product_eta]
          end
          if order[:stock_location_name] == "default"
            data3[:product_eta] = "In Stock & Ships The Same Business Day"
          end
          data1.merge!(data3)
          dborder = RetoolOrder.find_or_create_by(item_id: order[:item_id],shipment_number: order[:shipment_number]) 
          dborder.update(data1)
          process_oder_id << dborder.id
        end
        RetoolOrder.where.not(id: process_oder_id).delete_all
      end
      render json: "success".to_json, status: :ok
    end

    def update_record
      if params.present?
        params[:Key1].each do |order|
          data1 = {order_id: order[:order_id],
              order_number: order[:order_number],
              shipment_number: order[:shipment_number],
              email: order[:email],
              product_name: order[:product_name],
              order_state: order[:order_state],
              shipment_state: order[:shipment_state],
              payment_state: order[:payment_state],
              completed_at: order[:completed_at],
              store_location_id: order[:store_location_id],
              stock_location_name: order[:stock_location_name],
              eta_date: order[:estimated_eta],
              contracted_date: order[:contracted_date]}
          RetoolOrder.find_or_create_by(item_id: order[:item_id],shipment_number: order[:shipment_number]).update(data1)
        end
      end
      render json: "success".to_json, status: :ok
    end

  end
end