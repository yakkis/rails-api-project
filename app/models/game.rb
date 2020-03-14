# frozen_string_literal: true

class Game < ApplicationRecord
  include ActiveModel::Serializers::JSON

  # Game statuses
  ONGOING  = 'ongoing'
  ENDED    = 'ended'
  STATUSES = [ONGOING, ENDED].freeze

  # The maximum score in a bowling game should be 300
  MAX_SCORE = 300

  has_many :frames, dependent: :destroy
  has_many :throws, through: :frames

  validates :status, inclusion: { in: STATUSES }
  validates :total_score, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: MAX_SCORE,
    message: 'must be in range [0, 300]'
  }

  def attributes
    {
      'id' => 0,
      'status' => '',
      'total_score' => 0,
      'timestamp' => '',
      'frames' => []
    }
  end

  def timestamp
    updated_at.iso8601
  end

  def ongoing?
    status == ONGOING
  end

  def ended?
    status == ENDED
  end

  def end
    self.status = ENDED
  end

  # Calculate and save the game's total score
  # rubocop:disable Metrics/AbcSize
  def calculate_total_score
    total = 0
    frame = 1

    # Take the first score out of the rest
    first, *rest = scores_flattened
    # Abort if the game has no frames
    return if first.nil?

    # Loop until all the throw scores have been summed
    loop do
      # If the first throw is a strike
      if first == 10
        # Add 10 + the score of the next two throws
        total += 10 + sum_scores(rest, 2)
      else
        # Take the second score out of the rest
        second, *rest = rest

        # Abort if there are no more scores to count
        if second.nil?
          total += first
          break
        end

        # If the first and second throws form a spare
        total += if first + second == 10
                   # Add 10 + the score of the next throw
                   10 + sum_scores(rest, 1)
                 else
                   # Else add the first and second throw scores
                   first + second
                 end
      end

      # Abort if processing the last frame
      break if frame >= 10

      # Increment the frame number
      frame += 1
      # Reassign the first and rest variables and loop again
      first, *rest = rest

      # Abort if there are no more scores to count
      break if first.nil?
    end

    self.total_score = total
  end
  # rubocop:enable Metrics/AbcSize

  private

  # Flatten all game's throw scores into a single array
  # E.g. [2, 3, 0, 7, 5, 5, 8, 1, 10, 5]
  def scores_flattened
    frames.map { |f| f.throws.map(&:score) }.flatten
  end

  # Take 'amount' number of values from 'scores' and sum them up
  def sum_scores(scores, amount)
    scores.take(amount).sum
  end
end
