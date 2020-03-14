# frozen_string_literal: true

class GamesController < ApplicationController
  # GET /api/games
  def index
    # Leave out associations from index route data
    json = Game.all.to_json(only: %i[id status total_score timestamp])
    render json: json, status: :ok
  end

  # GET /api/games/:id
  def show
    game = Game.includes(:frames, :throws).find_by(id: params[:id])

    if game
      render json: game, status: :ok
    else
      render json: { errors: ['Game not found'] }, status: :not_found
    end
  end

  # POST /api/games
  def create
    game = Game.new(status: Game::ONGOING, total_score: 0)

    if game.save
      render json: game, status: :created
    else
      render json: game.errors, status: :unprocessable_entity
    end
  end
end
