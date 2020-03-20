# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Frame, type: :model do
  before(:each) do
    @game = Game.create(status: Game::ONGOING)
  end

  it 'is valid with valid attributes' do
    frame = Frame.new(game: @game, status: Frame::OPEN, number: 1)
    expect(frame).to be_valid
    frame = Frame.new(game: @game, status: Frame::OPEN, number: 10)
    expect(frame).to be_valid
  end

  it 'is invalid with invalid attributes' do
    frame = Frame.new(game: @game, status: Frame::OPEN, number: 0)
    expect(frame).not_to be_valid
    frame = Frame.new(game: @game, status: Frame::OPEN, number: 11)
    expect(frame).not_to be_valid
    frame = Frame.new(game: @game, status: 'bratwurst', number: 5)
    expect(frame).not_to be_valid
  end
end
