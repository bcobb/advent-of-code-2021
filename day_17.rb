class Day17
  def self.from_file_location(file_location)
    x_range, y_range = File.read(file_location).strip.then do |contents|
      min_x, max_x, min_y, max_y = contents.scan(/target area: x=([\-\d]+)\.\.([\-\d]+), y=([\-\d]+)\.\.([\-\d]+)/).first.map(&:to_i)

      [min_x..max_x, min_y..max_y]
    end

    new(target: Target.new(x_range: x_range, y_range: y_range))
  end

  def initialize(target:)
    @target = target
  end

  def first_solution
    @target.multi_move_starting_values.flat_map(&:last).map(&:last).max
  end

  def second_solution
    @target.multi_move_starting_values.length + @target.one_move_starting_values.length
  end

  class Target
    def initialize(x_range:, y_range:)
      @x_range = x_range
      @y_range = y_range
    end

    def one_move_starting_values
      @x_range.flat_map do |dx|
        @y_range.map do |dy|
          [dx, dy]
        end
      end
    end

    def multi_move_starting_values
      dy_projections = (@y_range.max.succ..(@y_range.size * FUDGE_FACTOR)).map do |dy|
        [dy, VerticalSequence.new(dy: dy)]
      end.flat_map do |dy, y_path|
        y_path = y_path.take_while { |y| y >= @y_range.min }

        (1..@x_range.min.pred).map do |dx|
          [[dx, dy], HorizontalSequence.new(dx: dx).take(y_path.length).zip(y_path)]
        end.select do |_, path|
          path.any? do |x, y|
            @x_range.include?(x) && @y_range.include?(y)
          end
        end
      end
    end

    FUDGE_FACTOR = 4
  end

  class VerticalSequence
    include Enumerable

    def initialize(dy:)
      @dy = dy
    end

    def each(&block)
      to_enum.each(&block)
    end

    def to_enum
      Enumerator.new do |e|
        y = 0
        step = @dy

        loop do
          e << y
          y += step
          step -= 1
        end
      end
    end
  end

  class HorizontalSequence
    include Enumerable

    def initialize(dx:)
      @dx = dx
    end

    def each(&block)
      to_enum.each(&block)
    end

    def to_enum
      Enumerator.new do |e|
        step = @dx
        x = 0

        loop do
          e << x
          x += step

          if step > 0
            step -= 1
          end
        end
      end
    end
  end
end
