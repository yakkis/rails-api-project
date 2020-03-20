# frozen_string_literal: true

# Register an amount of downed pins to a game instance
class RegisterThrow
  attr_reader :errors

  def initialize(game, pins)
    @game          = game
    @throw_pins    = pins
    @frame_pins    = 0
    @previous_pins = 0
    @frame         = nil
    @throw         = nil
    @errors        = []
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

    # Save the amount of downed pins in this frame
    @previous_pins, @frame_pins = calculate_frame_pins
    return false unless valid_frame?

    @frame.close if close_frame?
    @game.end if end_game?

    transaction
  end

  private

  # Return an open frame where a new throw can be registered
  def open_frame
    frame = @game.frames.max { |a, b| a.number <=> b.number }
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
    thrw = Throw.new(frame: @frame, score: @throw_pins, number: number)
    @errors.concat(thrw.errors.full_messages) unless thrw.valid?
    thrw
  end

  # For the frame, calculate the sum of throws' pins
  def calculate_frame_pins
    previous_pins = @frame.throws.map(&:score).sum
    current_pins  = previous_pins + @throw_pins
    [previous_pins, current_pins]
  end

  def valid_frame?
    # Validate frame's throws
    unless valid_frame_throws?
      @errors.push('Maximum frame pins exceeded')
      return false
    end

    true
  end

  # Validate downed pins for the current frame
  def valid_frame_throws?
    # Downed pins must be <= 10 for every frame expect the last
    return @frame_pins <= 10 unless @frame.last_frame?
    return valid_last_frame_first_throw? if @throw.first_throw?
    return valid_last_frame_nth_throw?(10) if @throw.second_throw?
    return valid_last_frame_nth_throw?(20) if @throw.third_throw?
  end

  def valid_last_frame_first_throw?
    # Downed pins must be <= 10 for last frame's first throw
    @frame_pins <= 10
  end

  def valid_last_frame_nth_throw?(base)
    # On the second throw, pins must be <= 10 if the previous throw was not a strike
    # On the third throw, pins must be <= 20 if the two previous throws made a spare
    return @frame_pins <= base if @previous_pins < base

    # On the second throw, pins must be <= 20 if the previous throw was a strike
    # On the third throw, pins must be <= 30 if the two previous throws were strikes
    @frame_pins <= base + 10
  end

  # Determine whether the current frame should be closed
  def close_frame?
    return close_normal_frame? unless @frame.last_frame?

    close_last_frame?
  end

  def close_normal_frame?
    # Close the frame if the first throw is a strike
    return @throw.strike? if @throw.first_throw?

    # Otherwise, always close the frame on the second throw
    true
  end

  def close_last_frame?
    # Last frame's first throw never closes a frame
    return false if @throw.first_throw?
    # Close if the last frame's second throw doesn't make a spare
    return @frame_pins < 10 if @throw.second_throw?

    # Otherwise, the third throw always closes the last frame
    true
  end

  # End the game if it's the last throw of the last frame
  def end_game?
    @frame.last_frame? && @frame.closed?
  end

  def transaction
    success = false

    ActiveRecord::Base.transaction do
      # Save the new throw and update game state
      success = @game.save && @frame.save && @throw.save
      # Game has to be reloaded prior to score calculations
      @game.reload
      # The throw has been validated and saved, so calculate the total scores
      success &&= @game.calculate_total_score

      unless success
        @errors.push('Saving to database failed')
        raise ActiveRecord::Rollback
      end
    end

    success
  end
end
