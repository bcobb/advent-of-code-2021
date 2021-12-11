class Day11
  def self.from_file_location(file_location)
    matrix = File.read(file_location).lines.map(&:strip).map do |line|
      line.chars.map { |char| Integer(char) }
    end

    new(matrix: matrix)
  end

  class Grid
    def initialize(matrix:)
      @matrix = matrix
    end

    attr_reader :flash_count

    def steps
      Enumerator.new do |e|
        step_matrix = @matrix.map(&:dup)

        loop do
          index = {}

          step_matrix.each.with_index do |column_values, row|
            column_values.each.with_index do |value, column|
              index[[row, column]] = value.succ
            end
          end

          flash_queue = index.select do |_, value|
            value > 9
          end.keys

          flashes = Set.new

          while flash_queue.any?
            flash_coordinate = flash_queue.shift

            if flashes.include?(flash_coordinate)
              next
            end

            flashes << flash_coordinate

            neighbors_of(*flash_coordinate).each do |neighbor_coordinate|
              index[neighbor_coordinate] += 1

              if index[neighbor_coordinate] > 9
                flash_queue << neighbor_coordinate
              end
            end
          end

          next_matrix = step_matrix.map do |row|
            row.map { nil }
          end

          index.each do |(row, column), value|
            if value > 9
              next_matrix[row][column] = 0
            else
              next_matrix[row][column] = value
            end
          end

          step_matrix = next_matrix
          e << next_matrix
        end
      end
    end

    def neighbors_of(row, column)
      Enumerator.new do |e|
        [
          [-1, -1],
          [-1, 0],
          [-1, 1],
          [0, -1],
          [0, 1],
          [1, -1],
          [1, 0],
          [1, 1],
        ].each do |d_row, d_column|
          neighbor_row = d_row + row
          neighbor_column = d_column + column

          if neighbor_row >= 0 && neighbor_column >= 0 && Array(@matrix[neighbor_row])[neighbor_column]
            e << [neighbor_row, neighbor_column]
          end
        end
      end
    end
  end

  def initialize(matrix:)
    @matrix = matrix
  end

  def first_solution
    Grid.new(matrix: @matrix).steps.first(100).flatten.count(&:zero?)
  end

  def second_solution
    Grid.new(matrix: @matrix).steps.take_while { |matrix| matrix.flatten.any? { |v| !v.zero? } }.length.succ
  end
end
