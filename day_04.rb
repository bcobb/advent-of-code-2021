class Day04
  def self.from_file_location(file_location)
    drawings_input, *board_inputs = File.read(file_location).split(/\n{2}/)

    drawings = drawings_input.split(",").map { |drawing| Integer(drawing) }
    boards = board_inputs.map do |board_input|
      board_matrix = board_input.lines.map do |row|
        row.strip.split(/\s+/).map do |place|
          Integer(place)
        end
      end

      Board.new(board_matrix)
    end

    new(drawings: drawings, boards: boards)
  end

  class WinCondition
    def initialize(turns:, score:)
      @turns = turns
      @score = score
    end

    def winning_turn
      @turns.last
    end

    def turns_to_win
      @turns.length
    end

    attr_reader :score
  end

  class Board
    def initialize(matrix)
      @rows = matrix
      @columns = matrix.transpose
    end

    def win_condition(drawings)
      winning_turns = drawings.each_with_object([]) do |drawing, turns|
        turns << drawing

        break turns if (@rows + @columns).any? do |numbers|
          numbers.all? { |n| turns.include?(n) }
        end
      end

      score = @rows.flatten.reject { |n| winning_turns.include?(n) }.sum

      WinCondition.new(turns: winning_turns, score: score)
    end
  end

  def initialize(drawings:, boards:)
    @drawings = drawings
    @boards = boards
  end

  def first_solution
    best_win_condition = @boards
      .map { |board| board.win_condition(@drawings) }
      .sort_by(&:turns_to_win)
      .first

      best_win_condition.score * best_win_condition.winning_turn
  end

  def second_solution
    worst_win_condition = @boards
      .map { |board| board.win_condition(@drawings) }
      .sort_by(&:turns_to_win)
      .last

    worst_win_condition.score * worst_win_condition.winning_turn
  end
end
