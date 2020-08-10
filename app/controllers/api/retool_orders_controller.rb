module Api
  class RetoolOrdersController < ApplicationController
    protect_from_forgery except: :update
    def index
      @orders = RetoolOrder.all
    end

    def update
      params[:_json].each do |order|
        RetoolOrder.find_or_create_by(order_id: order[:order_id]).update(eta_date: order[:"Calculated Column 2"], contracted_date: order[:"Calculated Column 1"])
      end
      render json: "success".to_json, status: :ok
    end

  end
end