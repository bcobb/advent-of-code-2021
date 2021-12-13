class Day13
  def self.from_file_location(file_location)
    coordinates, instructions = File.read(file_location).lines.map(&:strip).partition do |line|
      line.match(/^\d/)
    end

    coordinates.map! do |s|
      s.split(",").map { |x| Integer(x) }
    end

    instructions.reject!(&:empty?)
    instructions.map! do |s|
      fixed_coordinate, value = s.match(/(x|y)=(\d+)/).to_a.last(2)

      [fixed_coordinate, Integer(value)]
    end

    new(coordinates: coordinates, instructions: instructions)
  end

  class Folder
    def fold(coordinates:, instruction:)
      fixed_coordinate, fixed_value = instruction

      transformers = {
        "y" => lambda do |(column, row)|
          if row < fixed_value
            [column, row]
          else
            distance_from_fold = row - fixed_value

            [column, fixed_value - distance_from_fold]
          end
        end,
        "x" => lambda do |(column, row)|
          if column < fixed_value
            [column, row]
          else
            distance_from_fold = column - fixed_value

            [fixed_value - distance_from_fold, row]
          end
        end
      }

      transformer = transformers.fetch(fixed_coordinate)

      coordinates.map(&transformer).uniq
    end
  end

  class Printer
    def format(coordinates)
      max_column = coordinates.map(&:first).max
      max_row = coordinates.map(&:last).max

      template = (0..max_row).map do |row|
        (0..max_column).map do |column|
          coordinates.include?([column, row]) ? "#" : "."
        end
      end

      template.map do |row|
        row.join("")
      end
    end
  end

  def initialize(coordinates:, instructions:)
    @coordinates = coordinates
    @instructions = instructions
  end

  def first_solution
    folder = Folder.new
    folder.fold(coordinates: @coordinates, instruction: @instructions.first).count
  end

  def second_solution
    folder = Folder.new
    printer = Printer.new

    final_coordinates = @instructions.reduce(@coordinates) do |wip_coordinates, instruction|
      folder.fold(coordinates: wip_coordinates, instruction: instruction)
    end

    puts printer.format(final_coordinates)
  end
end
