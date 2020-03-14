# frozen_string_literal: true

# Register an amount of downed pins to a game instance
# NOTE: Scores in this class mean downed pins, not the total game score
class RegisterThrow
  attr_reader :errors

  def initialize(game, score)
    @game        = game
    @throw_score = score
    @frame_score = 0
    @frame       = nil
    @throw       = nil
    @errors      = []
  end

  # Create and validate necessary model instances
  # On success, return true
  # On failure, save errors to @errors and return false
  def call
    # Get/create an open game frame instance
    @frame = open_frame
    return false if @frame.nil? || @frame.invalid?

    # Create a new throw instance
    @throw = new_throw
    return false if @throw.invalid?

    # Save the amount of downed pins in this frame to @frame_score
    @frame_score = calculate_frame_score

    return false unless valid_frame?

    @frame.close if close_frame?
    @game.end if end_game?

    transaction
  end

  private

  # Return an open frame where a new throw can be registered
  def open_frame
    frame = @game.frames.order(:number).last
    # Game doesn't have any frames yet, so create the first one
    return new_frame(1) if frame.nil?
    # Last frame is still open, so return it
    return frame if frame.open?

    new_frame(frame.number + 1)
  end

  def new_frame(number)
    frame = Frame.new(game: @game, status: Frame::OPEN, number: number)
    @errors.concat(frame.errors.full_messages) unless frame.valid?
    frame
  end

  def new_throw
    number = @frame.throws.count + 1
    thrw = Throw.new(frame: @frame, score: @throw_score, number: number)
    @errors.concat(thrw.errors.full_messages) unless thrw.valid?
    thrw
  end

  # For the frame, calculate the sum of throws' scores
  def calculate_frame_score
    prev_score = @frame.throws.map(&:score).sum
    prev_score + @throw_score
  end

  # Validate the current frame
  def valid_frame?
    unless frame_score_valid?
      @errors.push('Maximum frame score exceeded')
      return false
    end

    true
  end

  # Validate score for the current frame
  def frame_score_valid?
    # Downed pins must be <= 10 for every frame expect the last
    return @frame_score <= 10 unless @frame.last_frame?
    # Downed pins must be <= 10 for last frame's first throw
    return @frame_score <= 10 if @throw.first_throw?

    prev_score = @frame_score - @throw_score

    if @throw.second_throw?
      # Downed pins must be <= 10 if the previous throw was not a strike
      return @frame_score <= 10 if prev_score < 10

      # Downed pins must be <= 20 if the previous throw was a strike
      return @frame_score <= 20
    end

    # Downed pins must be <= 20 if the two previous throws made a spare
    return @frame_score <= 20 if prev_score < 20

    # Downed pins must be <= 30 if the two previous throws were strikes
    @frame_score <= 30
  end

  # Determine whether the current frame should be closed
  def close_frame?
    # Close if the throw is a strike, but not on the last frame
    return @throw.strike? && !@frame.last_frame? if @throw.first_throw?

    if @throw.second_throw?
      # Close if on the last frame and frame's throws don't form a spare
      return @frame_score < 10 if @frame.last_frame?
    end

    # Otherwise, always close the frame
    true
  end

  # End the game if it's the last throw of the last frame
  def end_game?
    @frame.last_frame? && @frame.closed?
  end

  def transaction
    success = false

    ActiveRecord::Base.transaction do
      success = @game.save && @frame.save && @throw.save
      @game.reload
      @game.calculate_total_score
      success &&= @game.save

      unless success
        @errors.push('Saving to database failed')
        raise ActiveRecord::Rollback
      end
    end

    success
  end
end
