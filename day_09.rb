class Day09
  def self.from_file_location(file_location)
    rows = File.read(file_location).lines.map(&:strip)

    matrix = rows.map do |row|
      row.chars.map do |char|
        Integer(char)
      end
    end

    new(map: Map.new(matrix: matrix))
  end

  class Map
    def initialize(matrix:)
      @matrix = matrix
    end

    def basins
      wip_basins = {}

      points.each do |value, *coordinate|
        next if value == 9

        queue = [coordinate]

        while queue.any?
          coordinate = queue.shift
          next if wip_basins[coordinate]

          basin = neighbors_of(@matrix, *coordinate).map do |value, *neighbor_coordinate|
            wip_basins[neighbor_coordinate]
          end.compact.first

          basin ||= Basin.new
          basin << coordinate
          wip_basins[coordinate] = basin

          neighbors_of(@matrix, *coordinate).each do |neighbor_value, *neighbor_coordinate|
            queue << neighbor_coordinate if neighbor_value != 9
          end
        end
      end

      wip_basins.values.uniq
    end

    def total_risk_level
      low_points.sum { |value, _, _| value.succ }
    end

    def low_points
      points.select do |value, row, column|
        neighbors_of(@matrix, row, column).all? do |neighbor_value, _, _|
          value < neighbor_value
        end
      end
    end

    def points
      Enumerator.new do |e|
        @matrix.each.with_index do |column_values, row|
          column_values.each.with_index do |value, column|
            e << [value, row, column]
          end
        end
      end
    end

    private

    def neighbors_of(matrix, row, column)
      RELATIVE_NEIGHBOR_COORDINATES.map do |d_row, d_column|
        [Array(matrix[row + d_row])[column + d_column], row + d_row, column + d_column]
      end.select do |neighbor_value, neighbor_row, neighbor_column|
        neighbor_value && neighbor_row >= 0 && neighbor_column >= 0
      end
    end

    RELATIVE_NEIGHBOR_COORDINATES = [[1, 0], [0, 1], [0, -1], [-1, 0]]

    class Basin
      def initialize
        @coordinates = Set.new
      end

      attr_reader :coordinates

      def <<(coordinate)
        @coordinates << coordinate
      end

      def size
        @coordinates.size
      end
    end
  end

  def initialize(map:)
    @map = map
  end

  def first_solution
    @map.total_risk_level
  end

  def second_solution
    @map.basins.sort_by(&:size).last(3).map(&:size).reduce(&:*)
  end
end
