# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Throw, type: :model do
  before(:each) do
    @game = Game.create(status: Game::ONGOING, total_score: 0)
    @frame = Frame.create(game: @game, status: Frame::OPEN, number: 1)
  end

  it 'is valid with valid attributes' do
    thrw = Throw.new(frame: @frame, score: 0, number: 1)
    expect(thrw).to be_valid
    thrw = Throw.new(frame: @frame, score: Throw::MAX_SCORE, number: 3)
    expect(thrw).to be_valid
  end

  it 'is invalid with invalid attributes' do
    thrw = Throw.new(frame: @frame, score: 0, number: 0)
    expect(thrw).not_to be_valid
    thrw = Throw.new(frame: @frame, score: 0, number: 4)
    expect(thrw).not_to be_valid
    thrw = Throw.new(frame: @frame, score: -1, number: 1)
    expect(thrw).not_to be_valid
    thrw = Throw.new(frame: @frame, score: Throw::MAX_SCORE + 1, number: 1)
    expect(thrw).not_to be_valid
  end
end
