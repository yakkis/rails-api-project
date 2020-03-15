# frozen_string_literal: true

class ThrowsController < ApplicationController
  before_action :validate_score, only: %i[create]

  # POST /api/games/:game_id/throws
  def create
    game = Game.game_with_associations(params[:game_id])

    if game.nil?
      render json: { errors: ['Game not found'] }, status: :not_found
      return
    elsif game.ended?
      render json: { errors: ['Game has already ended'] }, status: :bad_request
      return
    end

    service = RegisterThrow.new(game, throw_params)

    if service.call
      head :created
    else
      render json: { errors: service.errors }, status: :unprocessable_entity
    end
  end

  private

  def validate_score
    return if Throw.score_in_range?(throw_params)

    message = { errors: ['Score must be in range [0, 10]'] }
    render json: message, status: :unprocessable_entity
  end

  def throw_params
    params.require(:throw).require(:score)
  end
end
