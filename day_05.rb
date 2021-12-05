class Day05
  def self.from_file_location(file_location)
    lines = File.read(file_location).lines.map(&:strip).map do |line|
      origin, destination = line.split(" -> ").map do |string_pair|
        x, y = string_pair.split(",").map do |n|
          Integer(n)
        end

        Point.new(x: x, y: y)
      end

      Line.new(origin: origin, destination: destination)
    end

    new(lines: lines.compact)
  end

  class Point
    def initialize(x:, y:)
      @x = x
      @y = y
      @hash = self.class.hash ^ { x: @x, y: @y }.hash
    end

    def inspect
      "(#{@x},#{@y})"
    end

    def ==(other)
      eql?(other)
    end

    def eql?(other)
      self.class == other.class && other.hash == hash
    end

    def next_point_towards(other)
      x_step = begin
        (other.x - x) / (other.x - x).abs
      rescue ZeroDivisionError
        0
      end

      y_step = begin
        (other.y - y) / (other.y - y).abs
      rescue ZeroDivisionError
        0
      end

      Point.new(x: x + x_step, y: y + y_step)
    end

    attr_reader :hash
    attr_reader :x
    attr_reader :y
  end

  class Line
    include Enumerable

    def initialize(origin:, destination:)
      @origin = origin
      @destination = destination
    end

    def flat?
      @origin.x == @destination.x || @origin.y == @destination.y
    end

    def each
      current = @origin

      loop do
        yield current

        break if current == @destination

        current = current.next_point_towards(@destination)
      end
    end
  end

  def initialize(lines:)
    @lines = lines
  end

  def first_solution
    @lines.
      select(&:flat?).
      map(&:to_a).
      flatten.
      group_by(&:itself).
      count { |_, values| values.length > 1 }
  end

  def second_solution
    @lines.
      map(&:to_a).
      flatten.
      group_by(&:itself).
      count { |_, values| values.length > 1 }
  end
end
