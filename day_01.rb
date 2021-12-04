class Day01
  def self.from_file_location(file_location)
    input = File.read(file_location).lines.map(&:strip).map { |line| Integer(line) }

    new(input)
  end

  def initialize(measurements)
    @measurements = measurements
  end

  def first_solution
    @measurements.each_cons(2).count { |a, b| b > a }
  end

  def second_solution
    windows = @measurements.each_cons(3)

    windows.each_cons(2).count { |a, b| b.sum > a.sum }
  end
end
