module Api
  require 'open-uri'
  require "uri"
  require "net/http"
  require "google_drive"
  require "googleauth"
  class RetoolTestApiController < ApplicationController
    protect_from_forgery except: :test
    def test
      pdf = open(params["html"]["url"])
      session = GoogleDrive::Session.from_config('config/drive_config.json')
      response = session.upload_from_file(pdf, params["html"]["name"], convert: false, parents: ["1ZgzHBHzK2CZR54TFgly0ozM8aZdcpuXY"])
      if response.title.present?
        render json: JSON.parse({code: 200, message: "File uploaded successfully"}), status: :ok
      else
        render json: JSON.parse({message: "File uploading filed"}), status: :error
      end
    end
  end
end