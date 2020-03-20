# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ThrowsController, type: :controller do
  let(:auth_header) do
    token = JWT.encode({}, Rails.application.secret_key_base, 'HS256')
    { 'Authorization': "Bearer #{token}" }
  end

  describe 'POST create' do
    # Worst score
    let(:throws_1) do
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    end
    # Best score
    let(:throws_2) do
      [10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10]
    end
    # Random scores with no extra throw in the last frame
    let(:throws_3) do
      [0, 5, 10, 7, 0, 2, 3, 0, 0, 7, 3, 10, 2, 6, 9, 0, 4, 3]
    end
    # Random scores with extra throw in the last frame
    let(:throws_4) do
      [1, 5, 5, 5, 10, 2, 3, 1, 0, 7, 3, 10, 2, 6, 9, 0, 10, 10, 10]
    end
    # Random scores with extra throw in the last frame
    let(:throws_5) do
      [1, 6, 5, 5, 10, 10, 1, 0, 7, 3, 7, 1, 2, 6, 9, 0, 2, 8, 5]
    end

    before(:each) do
      @game = Game.create(status: Game::ONGOING, total_score: 0)
    end

    it 'returns HTTP status 401 without a valid token' do
      params = { game_id: @game.id, throw: { score: 5 } }
      post :create, params: params, as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it 'handles the worst score correctly' do
      throws_1.each do |score|
        request.headers.merge!(auth_header)
        params = { game_id: @game.id, throw: { score: score } }
        post :create, params: params, as: :json
        expect(response).to have_http_status(:created)
      end
      @game.reload
      expect(@game.total_score).to eq(0)
    end

    it 'handles the best score correctly' do
      throws_2.each do |score|
        request.headers.merge!(auth_header)
        params = { game_id: @game.id, throw: { score: score } }
        post :create, params: params, as: :json
        expect(response).to have_http_status(:created)
      end
      @game.reload
      expect(@game.total_score).to eq(300)
    end

    it 'handles random scores with no extra throws in the last frame' do
      throws_3.each do |score|
        request.headers.merge!(auth_header)
        params = { game_id: @game.id, throw: { score: score } }
        post :create, params: params, as: :json
        expect(response).to have_http_status(:created)
      end
      @game.reload
      expect(@game.total_score).to eq(96)
    end

    it 'handles random scores with extra throws in the last frame' do
      throws_4.each do |score|
        request.headers.merge!(auth_header)
        params = { game_id: @game.id, throw: { score: score } }
        post :create, params: params, as: :json
        expect(response).to have_http_status(:created)
      end
      @game.reload
      expect(@game.total_score).to eq(132)
    end

    it 'handles random scores with extra throws in the last frame' do
      throws_5.each do |score|
        request.headers.merge!(auth_header)
        params = { game_id: @game.id, throw: { score: score } }
        post :create, params: params, as: :json
        expect(response).to have_http_status(:created)
      end
      @game.reload
      expect(@game.total_score).to eq(117)
    end

    it 'handles invalid frame score' do
      [0, 0, 2, 2, 5].each do |score|
        request.headers.merge!(auth_header)
        params = { game_id: @game.id, throw: { score: score } }
        post :create, params: params, as: :json
        expect(response).to have_http_status(:created)
      end

      @game.reload
      expect(@game.total_score).to eq(9)

      request.headers.merge!(auth_header)
      params = { game_id: @game.id, throw: { score: 6 } }
      post :create, params: params, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'handles invalid frame score in the last frame' do
      [10, 10, 10, 10, 10, 10, 10, 10, 10, 3].each do |score|
        request.headers.merge!(auth_header)
        params = { game_id: @game.id, throw: { score: score } }
        post :create, params: params, as: :json
        expect(response).to have_http_status(:created)
      end

      @game.reload
      expect(@game.total_score).to eq(249)

      request.headers.merge!(auth_header)
      params = { game_id: @game.id, throw: { score: 10 } }
      post :create, params: params, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'handles invalid score' do
      request.headers.merge!(auth_header)
      params = { game_id: @game.id, throw: { score: 11 } }
      post :create, params: params, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'does not add throws to a non-existent game' do
      request.headers.merge!(auth_header)
      params = { game_id: '12345', throw: { score: 1 } }
      post :create, params: params, as: :json
      expect(response).to have_http_status(:not_found)
    end

    it 'does not add throws to a closed game' do
      [10, 10, 10, 10, 10, 10, 10, 10, 10, 0, 0].each do |score|
        request.headers.merge!(auth_header)
        params = { game_id: @game.id, throw: { score: score } }
        post :create, params: params, as: :json
        expect(response).to have_http_status(201)
      end

      @game.reload
      expect(@game.total_score).to eq(240)

      request.headers.merge!(auth_header)
      params = { game_id: @game.id, throw: { score: 1 } }
      post :create, params: params, as: :json
      expect(response).to have_http_status(:bad_request)
    end

    it 'handles database errors' do
      request.headers.merge!(auth_header)
      allow_any_instance_of(Game).to receive(:calculate_total_score).and_return(false)
      params = { game_id: @game.id, throw: { score: 1 } }
      post :create, params: params, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
