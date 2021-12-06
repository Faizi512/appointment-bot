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

          data1 = {order_id: params["Key1"][:order_id],
              order_number: params["Key1"][:order_number],
              shipment_number: params["Key1"][:shipment_number],
              email: params["Key1"][:email],
              product_name: params["Key1"][:product_name],
              order_state: params["Key1"][:order_state],
              shipment_state: params["Key1"][:shipment_state],
              payment_state: params["Key1"][:payment_state],
              completed_at: params["Key1"][:completed_at],
              store_location_id: params["Key1"][:store_location_id],
              stock_location_name: params["Key1"][:stock_location_name]}

          data2 = {eta_date: params["Key1"][:estimated_eta],
              contracted_date: params["Key1"][:contracted_date]}

          if params["Key1"][:estimated_eta].present? || params["Key1"][:contracted_date].present?    
            data1.merge!(data2)
          end

          data3 = {product_eta: params["Key1"][:brand_eta]}

          if params["Key1"][:product_eta].present?
            data3[:product_eta] = params["Key1"][:product_eta]
          end

          if params["Key1"][:stock_location_name] == "default"
            data3[:product_eta] = "In Stock & Ships The Same Business Day"
          end

          data1.merge!(data3)

          dborder = RetoolOrder.find_or_create_by(item_id: params["Key1"][:item_id],shipment_number: params["Key1"][:shipment_number]) 
          dborder.update(data1)
          process_oder_id << dborder.id
        end

        # RetoolOrder.where.not(id: process_oder_id).delete_all
      end
      render json: "success".to_json, status: :ok
    end

    def update_record

      if params.present?
        params[:Key1].each do |order|

          data1 = {order_id: params["Key1"]["order_id"],
              order_number: params["Key1"][:order_number],
              shipment_number: params["Key1"][:shipment_number],
              email: params["Key1"][:email],
              product_name: params["Key1"][:product_name],
              order_state: params["Key1"][:order_state],
              shipment_state: params["Key1"][:shipment_state],
              payment_state: params["Key1"][:payment_state],
              completed_at: params["Key1"][:completed_at],
              store_location_id: params["Key1"][:store_location_id],
              stock_location_name: params["Key1"][:stock_location_name],
              eta_date: params["Key1"][:estimated_eta],
              contracted_date: params["Key1"][:contracted_date]}

          RetoolOrder.find_or_create_by(item_id: params["Key1"][:item_id],shipment_number: params["Key1"][:shipment_number]).update(data1)

        end
      end
      render json: "success".to_json, status: :ok
    end

  end
end