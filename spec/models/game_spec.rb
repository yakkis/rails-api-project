# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Game, type: :model do
  it 'is valid with valid attributes' do
    game = Game.new(status: Game::ONGOING, total_score: 0)
    expect(game).to be_valid
    game = Game.new(status: Game::ONGOING, total_score: Game::MAX_SCORE)
    expect(game).to be_valid
  end

  it 'is invalid with invalid attributes' do
    game = Game.new(status: Game::ONGOING, total_score: nil)
    expect(game).not_to be_valid
    game = Game.new(status: Game::ONGOING, total_score: -1)
    expect(game).not_to be_valid
    game = Game.new(status: Game::ONGOING, total_score: 301)
    expect(game).not_to be_valid
    game = Game.new(status: 'bratwurst', total_score: 0)
    expect(game).not_to be_valid
  end
end
