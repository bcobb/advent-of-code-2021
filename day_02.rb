class Day02
  def self.from_file_location(file_location)
    input = File.read(file_location).lines.map(&:strip).map do |line|
      direction, raw_amount = line.split(" ")

      Command.new(direction: direction, amount: Integer(raw_amount))
    end

    new(input)
  end

  class Command
    def initialize(direction:, amount:)
      @direction = direction
      @amount = amount
    end

    def horizontal_movement
      case @direction
      when "forward"
        @amount
      else
        0
      end
    end

    def vertical_movement
      case @direction
      when "up"
        -@amount
      when "down"
        @amount
      else
        0
      end
    end
  end

  class Position
    def initialize(horizontal: 0, depth: 0)
      @horizontal = horizontal
      @depth = depth
    end

    def apply(command)
      @horizontal += command.horizontal_movement
      @depth += command.vertical_movement
    end

    attr_reader :horizontal
    attr_reader :depth
  end

  class PositionWithAim
    def initialize(horizontal: 0, depth: 0, aim: 0)
      @horizontal = horizontal
      @depth = depth
      @aim = aim
    end

    def apply(command)
      @aim += command.vertical_movement
      @horizontal += command.horizontal_movement
      @depth += (@aim * command.horizontal_movement)
    end

    attr_reader :horizontal
    attr_reader :depth
  end

  def initialize(commands)
    @commands = commands
  end

  def first_solution
    final_position = @commands.each_with_object(Position.new) do |command, position|
      position.apply(command)
    end

    final_position.horizontal * final_position.depth
  end

  def second_solution
    final_position = @commands.each_with_object(PositionWithAim.new) do |command, position|
      position.apply(command)
    end

    final_position.horizontal * final_position.depth
  end
end
