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

  def ended?
    status == ENDED
  end

  def end
    self.status = ENDED
  end

  # Calculate and save game's total score
  # Returns a boolean indicating whether the total_score update succeeded of not
  def calculate_total_score
    # Get scores for all the game frames in a single array
    # E.g. [2, 3, 0, 7, 5, 5, 8, 1, 10, 5]
    scores = throws.map(&:score)
    # Abort if the game has no frames
    return true if scores[0].nil?

    # Call frame scoring loop with initial values
    frame_scores = scoring_loop([], 1, scores)

    update(total_score: frame_scores.sum)
  end

  private

  # Recursively execute scoring_loop until all the frame scores have been calculated
  def scoring_loop(result, frame, scores)
    # Take the first score out of the rest
    first, *rest = scores

    # Calculate frame's total score
    temp = if first == 10
             # If strike, return 10 + the sum of the next two throws
             sum_scores(rest, 2)
           else
             second, *rest = rest
             # If the frame is incomplete, add the first throw's score and return
             return result.push(first) if second.nil?

             # Calculate the total score for a frame with two throws
             two_throw_frame_score(first, second, rest)
           end

    result.push(temp)

    # Abort if there are no more scores to count or if processing the last frame
    return result if rest.empty? || frame >= 10

    # Loop again with new values
    scoring_loop(result, frame + 1, rest)
  end

  # Calculate the total score for a strike or a spare
  # Takes 10 and 'amount' number of values from 'scores' and sum them up
  def sum_scores(scores, amount)
    10 + scores.take(amount).sum
  end

  # Calculate the total score for a frame
  def two_throw_frame_score(first, second, rest)
    # If the first and second throws form a spare,
    # add 10 + the score of the next throw,
    # else return frame's first and second scores summed
    frame_total = first + second
    frame_total == 10 ? sum_scores(rest, 1) : frame_total
  end
end
