# frozen_string_literal: true

class Throw < ApplicationRecord
  include ActiveModel::Serializers::JSON

  # This API supports only 10 bowling pins at once
  MAX_SCORE = 10

  belongs_to :frame

  validates :score, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: MAX_SCORE,
    message: 'must be in range [0, 10]'
  }
  validates :number, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 3,
    message: 'must be in range [1, 3]'
  }

  def self.score_in_range?(value)
    value >= 0 && value <= MAX_SCORE
  end

  def attributes
    {
      'score' => 0,
      'number' => 0
    }
  end

  def first_throw?
    number == 1
  end

  def second_throw?
    number == 2
  end

  def strike?
    score >= MAX_SCORE
  end
end
