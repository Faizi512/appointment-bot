module Api
  class RetoolOrdersController < ApplicationController
    protect_from_forgery except: :update
    def index
      @orders = RetoolOrder.all
    end

    def update
      params[:retool_order].each do |order|
        RetoolOrder.find_or_create_by(order_id: order[:order_id]).update(eta_date: order[:eta_date], contracted_date: order[:contracted_date])
      end
      render json: "success".to_json, status: :ok
    end

  end
end