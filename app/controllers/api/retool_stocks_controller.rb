module Api
  class RetoolStocksController < ApplicationController
    protect_from_forgery except: :update
    def update
      if params.present?
        UpdateRetoolStocksJob.perform_now(params)
        render json: "success".to_json, status: :ok
      end
    end

  end
end