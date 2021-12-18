class Day15
  def self.from_file_location(file_location)
    matrix_values = File.read(file_location).lines.map(&:strip).map do |line|
      line.chars.map { |c| Integer(c) }
    end

    new(matrix: Matrix.new(values: matrix_values))
  end

  class Matrix
    def self.expand(matrix:, times:)
      new_values = (matrix.length * times).times.map do
        (matrix.length * times).times.map do
          nil
        end
      end

      scaling = times.times.flat_map do |i|
        times.times.map do |j|
          [i + j, i, j]
        end
      end

      matrix.points.each do |(value, row, column)|
        scaling.each do |(increment, row_offset, column_offset)|
          offset_value = value + increment

          final_value = offset_value > 9 ? ((offset_value % 10) + 1) : offset_value
          final_row = (matrix.length * row_offset) + row
          final_column = (matrix.length * column_offset) + column

          new_values[final_row][final_column] = final_value
        end
      end

      new(values: new_values)
    end

    def initialize(values:)
      @values = values
    end

    def length
      @values.length
    end

    def points
      Enumerator.new do |e|
        @values.each.with_index do |column_values, row|
          column_values.each.with_index do |value, column|
            e << [value, row, column]
          end
        end
      end
    end

    def neighbors_of(row, column)
      Enumerator.new do |e|
        [
          [0, 1],
          [1, 0],
          [-1, 0],
          [0, -1]
        ].map do |d_row, d_column|
          [row + d_row, column + d_column]
        end.filter do |neighbor_row, neighbor_column|
          neighbor_row >= 0 &&
            neighbor_column >= 0 &&
            Array(@values[neighbor_row])[neighbor_column]
        end.map do |neighbor_row, neighbor_column|
          e << [@values[neighbor_row][neighbor_column], neighbor_row, neighbor_column]
        end
      end
    end

    def to_formatted_s
      @values.map(&:join).join("\n")
    end
  end

  class Node
    def self.from_matrix(matrix)
      queue = matrix.points.to_a
      nodes_by_point = {}

      while queue.any?
        point = queue.shift

        nodes_by_point[point] ||= Node.new(value: point)
        node = nodes_by_point[point]
        _, point_row, point_column = point

        matrix.neighbors_of(point_row, point_column).each do |neighbor_point|
          nodes_by_point[neighbor_point] ||= Node.new(value: neighbor_point)
          neighbor_node = nodes_by_point[neighbor_point]

          neighbor_node.children << node
          node.children << neighbor_node
        end
      end

      nodes_by_point[matrix.points.first]
    end

    def initialize(value:)
      @value = value
      @children = Set.new
    end

    def inspect
      "#<Node value=#{value.inspect} children=#{children.map(&:value).inspect}>"
    end

    attr_reader :children
    attr_reader :value
  end

  def initialize(matrix:)
    @matrix = matrix
  end

  attr_reader :matrix

  def first_solution
    points = @matrix.points.to_a
    start = points.first
    finish = points.last
    _, finish_row, finish_column = finish

    heuristic = lambda do |(_, row, column)|
      (row - finish_row).abs + (column - finish_column).abs
    end

    a_star(@matrix, start, finish, heuristic)
  end

  def second_solution
    expanded = Matrix.expand(matrix: @matrix, times: 5)

    points = expanded.points.to_a
    start = points.first
    finish = points.last
    _, finish_row, finish_column = finish

    heuristic = lambda do |(_, row, column)|
      (row - finish_row).abs + (column - finish_column).abs
    end

    a_star(expanded, start, finish, heuristic)
  end

  def a_star(matrix, start, finish, heuristic)
    open_set = [start].to_set

    came_from = {}

    scores = Hash.new(Float::INFINITY)
    scores[start] = 0

    score_guesses = {
      start => heuristic.call(start)
    }

    while open_set.any?
      current = open_set.min_by do |node|
        score_guesses.fetch(node)
      end

      if current == finish
        return scores[current]
      end

      open_set.delete(current)

      _, current_row, current_column = current

      matrix.neighbors_of(current_row, current_column).each do |neighbor|
        neighbor_value, neighbor_row, neighbor_column = neighbor
        tenative_score = scores.fetch(current) + neighbor_value

        if tenative_score < scores[neighbor]
          came_from[neighbor] = current
          scores[neighbor] = tenative_score
          score_guesses[neighbor] = tenative_score + heuristic.call(neighbor)

          open_set << neighbor
        end
      end
    end
  end
end
