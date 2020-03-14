# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :authorize_request

  def not_found
    render json: { errors: ['Not found'] }, status: :not_found
  end

  private

  def authorize_request
    auth_header = request.headers['Authorization']
    token = auth_header.split(' ').last if auth_header
    secret = Rails.application.secret_key_base

    begin
      JWT.decode(token, secret, true, { algorithm: 'HS256' })
    rescue JWT::DecodeError => e
      message = { errors: ["#{e.class}: #{e.message}"] }
      render json: message, status: :unauthorized
    end
  end
end
