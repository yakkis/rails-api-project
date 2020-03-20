# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GamesController, type: :controller do
  let(:auth_header) do
    token = JWT.encode({}, Rails.application.secret_key_base, 'HS256')
    { 'Authorization': "Bearer #{token}" }
  end

  describe 'GET index' do
    it 'returns HTTP status 401 without a valid token' do
      get :index
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns an empty array' do
      request.headers.merge!(auth_header)
      get :index
      expect(response).to have_http_status(:ok)
      result = JSON.parse(response.body)
      expect(result).to eq([])
    end

    it 'returns games' do
      game = Game.create(status: Game::ONGOING, total_score: 0)
      expected = {
        'id' => 1,
        'status' => 'ongoing',
        'total_score' => 0,
        'timestamp' => game.timestamp
      }

      request.headers.merge!(auth_header)
      get :index
      expect(response).to have_http_status(:ok)
      result = JSON.parse(response.body)
      expect(result).to eq([expected])
    end
  end

  describe 'GET show' do
    it 'returns HTTP status 401 without a valid token' do
      get :show, params: { id: 5 }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'handles nonexistent game' do
      request.headers.merge!(auth_header)
      get :show, params: { id: 5 }
      expect(response).to have_http_status(:not_found)
    end

    it 'returns a game status' do
      game = Game.create(status: Game::ONGOING, total_score: 0)
      frame = Frame.create(game: game, status: Frame::OPEN, number: 1)
      Throw.create(frame: frame, score: 5, number: 1)
      game.calculate_total_score

      expected = {
        'id' => 1,
        'status' => 'ongoing',
        'total_score' => 5,
        'timestamp' => game.timestamp,
        'frames' => [
          {
            'status' => 'open',
            'number' => 1,
            'throws' => [
              {
                'score' => 5,
                'number' => 1
              }
            ]
          }
        ]
      }

      request.headers.merge!(auth_header)
      get :show, params: { id: 1 }
      expect(response).to have_http_status(:ok)
      result = JSON.parse(response.body)
      expect(result).to eq(expected)
    end
  end

  describe 'POST create' do
    it 'returns HTTP status 401 without a valid token' do
      post :create
      expect(response).to have_http_status(:unauthorized)
    end

    it 'return HTTP status 500 when game creation fails' do
      request.headers.merge!(auth_header)
      allow_any_instance_of(Game).to receive(:save).and_return(false)
      post :create
      expect(response).to have_http_status(:internal_server_error)
    end

    it 'creates a new game' do
      request.headers.merge!(auth_header)
      post :create
      expect(response).to have_http_status(:created)
    end
  end
end
