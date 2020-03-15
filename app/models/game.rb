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

  # Find a game by ID and include associations to reduce the amount of DB calls
  def self.game_with_associations(game_id)
    Game.includes(:frames, :throws).find_by(id: game_id)
  end

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

  # Calculate and save the game's and its frames total score
  # rubocop:disable Metrics/AbcSize
  def calculate_total_scores
    # Keep track of individual frame scores
    frame_scores = []
    frame = 1

    # Take the first score out of the rest
    first, *rest = scores_flattened
    # Abort if the game has no frames
    return if first.nil?

    # Loop until all the throw scores have been summed
    loop do
      temp = 0

      # If the first throw is a strike
      if first == 10
        # Add 10 + the score of the next two throws
        temp = 10 + sum_scores(rest, 2)
      else
        # Take the second score out of the rest
        second, *rest = rest

        # Abort if there are no more scores to count
        if second.nil?
          frame_scores.push(first)
          break
        end

        # If the first and second throws form a spare
        temp = if first + second == 10
                 # Add 10 + the score of the next throw
                 10 + sum_scores(rest, 1)
               else
                 # Else add the first and second throw scores
                 first + second
               end
      end

      frame_scores.push(temp)

      # Abort if processing the last frame
      break if frame >= 10

      # Increment the frame number
      frame += 1
      # Reassign the first and rest variables and loop again
      first, *rest = rest

      # Abort if there are no more scores to count
      break if first.nil?
    end

    success = update(total_score: frame_scores.sum)
    success &&= update_frame_scores(frame_scores)
    success
  end
  # rubocop:enable Metrics/AbcSize

  private

  # Game's throw scores in a single array
  # E.g. [2, 3, 0, 7, 5, 5, 8, 1, 10, 5]
  def scores_flattened
    throws.map(&:score)
  end

  # Take 'amount' number of values from 'scores' and sum them up
  def sum_scores(scores, amount)
    scores.take(amount).sum
  end

  def update_frame_scores(frame_scores)
    success = true
    frames.zip(frame_scores).each do |frame, score|
      success &&= frame.update(total_score: score)
    end
    success
  end
end
