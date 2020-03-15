# frozen_string_literal: true

class Frame < ApplicationRecord
  include ActiveModel::Serializers::JSON

  # Frame statuses
  OPEN     = 'open'
  CLOSED   = 'closed'
  STATUSES = [OPEN, CLOSED].freeze

  # A game has a maximum of 10 frames
  MAX_NUMBER = 10
  # A frame maximum score is 30
  MAX_TOTAL_SCORE = 30

  belongs_to :game
  has_many :throws, dependent: :destroy

  validates :status, inclusion: { in: STATUSES }
  validates :number, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: MAX_NUMBER,
    message: 'must be in range [1, 10]'
  }
  validates :total_score, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: MAX_TOTAL_SCORE,
    message: 'must be in range [0, 30]'
  }

  def attributes
    {
      'status' => '',
      'number' => 0,
      'total_score' => 0,
      'throws' => []
    }
  end

  def open?
    status == OPEN
  end

  def closed?
    status == CLOSED
  end

  def close
    self.status = CLOSED
  end

  def last_frame?
    number >= MAX_NUMBER
  end
end
