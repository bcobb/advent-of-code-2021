class Day03
  def self.from_file_location(file_location)
    input = File.read(file_location).lines.map(&:strip).map do |line|
      line.chars.map { |char| Integer(char) }
    end

    new(input)
  end

  class DiagnosticReport
    def initialize(numbers)
      @numbers = numbers
    end

    def gamma_rate
      report = self.class.compute_report(@numbers)

      self.class.binary_to_decimal(report.map(&:last))
    end

    def epsilon_rate
      report = self.class.compute_report(@numbers)

      self.class.binary_to_decimal(report.map(&:first))
    end

    def oxygen_generator_rating
      rating_by_bit_ranking(:most_common)
    end

    def scrubber_rating
      rating_by_bit_ranking(:least_common)
    end

    def rating_by_bit_ranking(ranking)
      index = 0
      rating_numbers = @numbers

      loop do
        if rating_numbers.length == 1
          break self.class.binary_to_decimal(rating_numbers.first)
        end

        report = self.class.compute_report(rating_numbers)

        if report[index].nil?
          raise "Index #{index} is out of bounds"
        end

        relevant_bit = case ranking
        when :most_common
          report[index].last
        when :least_common
          report[index].first
        else
          raise ArgumentError, "Ranking must be one of :most_common or :least_common, got #{ranking}"
        end

        rating_numbers = rating_numbers.select do |number|
          relevant_bit == number[index]
        end
        index += 1
      end
    end

    def self.binary_to_decimal(binary)
      binary.reverse.map.with_index.sum do |digit, index|
        digit * (2 ** index)
      end
    end

    def self.compute_report(numbers)
      indices = 0..numbers.first.length.pred

      indices.map do |index|
        column = numbers.map { |number| number[index] }

        column.
          # { 0 => [...], 1 => [...] }
          group_by(&:itself).
          # [[0, n], [1, m]]
          map { |n, ns| [n, ns.length] }.
          # sort by length, ties break in order of first bit
          sort_by { |n, length| [length, n] }.
          # only keep the bit value
          map(&:first)
      end
    end
  end

  def initialize(numbers)
    @numbers = numbers
  end

  def first_solution
    report = DiagnosticReport.new(@numbers)

    report.epsilon_rate * report.gamma_rate
  end

  def second_solution
    report = DiagnosticReport.new(@numbers)

    report.oxygen_generator_rating * report.scrubber_rating
  end
end
