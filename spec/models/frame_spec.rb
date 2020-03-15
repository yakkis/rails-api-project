# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Frame, type: :model do
  before(:each) do
    @game = Game.create(status: Game::ONGOING, total_score: 0)
  end

  it 'is valid with valid attributes' do
    frame = Frame.new(game: @game, status: Frame::OPEN, number: 1, total_score: 0)
    expect(frame).to be_valid
    frame = Frame.new(game: @game, status: Frame::OPEN, number: 10, total_score: 30)
    expect(frame).to be_valid
  end

  it 'is invalid with invalid attributes' do
    frame = Frame.new(game: @game, status: Frame::OPEN, number: 0, total_score: 0)
    expect(frame).not_to be_valid
    frame = Frame.new(game: @game, status: Frame::OPEN, number: 11, total_score: 0)
    expect(frame).not_to be_valid
    frame = Frame.new(game: @game, status: 'bratwurst', number: 5, total_score: 0)
    expect(frame).not_to be_valid
    frame = Frame.new(game: @game, status: Frame::OPEN, number: 5, total_score: 31)
    expect(frame).not_to be_valid
  end
end
