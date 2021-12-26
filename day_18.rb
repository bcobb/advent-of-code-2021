class Day18
  def self.from_array(array)
    new(arrays: [array])
  end

  def self.from_file_location(file_location)
    arrays = File.read(file_location).lines.map(&:strip).map do |line|
      eval(line) if line.match(/[\[\]\d,\s]+/)
    end

    new(arrays: arrays)
  end

  def initialize(arrays:)
    @arrays = arrays
  end

  def first_solution
    root = @arrays.map do |(left, right)|
      Pair.new(left: left, right: right)
    end.reduce(&:+)

    root.magnitude
  end

  def second_solution
    @arrays.flat_map do |(left_one, right_one)|
      @arrays.flat_map do |(left_two, right_two)|
        if left_one != left_two && right_one != right_two
          [
            (Pair.new(left: left_one, right: right_one) + Pair.new(left: left_two, right: right_two)).magnitude,
            (Pair.new(left: left_two, right: right_two) + Pair.new(left: left_one, right: right_one)).magnitude
          ]
        end
      end
    end.compact.max
  end

  class Node
    def initialize(value:, parent:)
      @value = value
      @parent = parent
    end

    attr_reader :value
    attr_accessor :parent

    def magnitude
      value
    end

    def left?
      parent&.left == self
    end

    def explode!
      false
    end

    def add_to_leaf(value:, direction:)
      @value += value
    end

    def split!
      if @value >= 10
        remainder = @value % 2
        quotient = @value / 2
        direction = left? ? :left : :right

        @parent.add_child(value: [quotient, quotient + remainder], direction: direction)

        true
      end
    end
  end

  class Pair
    def initialize(left:, right:, parent: nil)
      @parent = parent
      add_child(value: left, direction: :left)
      add_child(value: right, direction: :right)
    end

    attr_accessor :parent
    attr_accessor :left
    attr_accessor :right

    def magnitude
      (3 * left.magnitude) + (2 * right.magnitude)
    end

    def value
      [left.value, right.value]
    end

    def add_child(value:, direction:)
      setter = case direction
      when :left, :right
        method(:"#{direction}=")
      else
        raise ArgumentError, "unknown direction #{direction}"
      end

      child = case value
      when Array
        left, right = value

        Pair.new(left: left, right: right, parent: self)
      when Integer
        Node.new(value: value, parent: self)
      end

      setter.call(child)

      nil
    end

    def add_to_leaf(value:, direction:)
      child = case direction
      when :left, :right
        method(direction).call
      else
        raise ArgumentError, "unknown direction #{direction}"
      end

      child.add_to_leaf(value: value, direction: direction)
    end

    def +(other)
      Pair.new(left: self.value, right: other.value).tap do |result|
        loop do
          break unless result.explode! || result.split!
        end
      end
    end

    def depth
      case parent
      when nil
        0
      else
        parent.depth + 1
      end
    end

    def navigate_up(prefer:)
      current = self
      parent = current.parent

      while parent
        if (prefer == :left) && !current.left? || (prefer == :right) && current.left?
          return parent
        else
          current = parent
          parent = current.parent
        end
      end
    end

    def explode!
      if depth < 4
        left.explode! || right.explode!
      else
        left_parent = navigate_up(prefer: :left)

        if left_parent
          left_parent.left.add_to_leaf(value: left.value, direction: :right)
        end

        right_parent = navigate_up(prefer: :right)

        if right_parent
          right_parent.right.add_to_leaf(value: right.value, direction: :left)
        end

        parent.add_child(value: 0, direction: left? ? :left : :right)
      end
    end

    def split!
      left.split! || right.split!
    end

    def left?
      parent&.left == self
    end
  end
end
