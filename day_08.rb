class Day08
  DIGIT_ENCODINGS = {
    0 => %w(a b c e f g),
    1 => %w(c f),
    2 => %w(a c d e g),
    3 => %w(a c d f g),
    4 => %w(b c d f),
    5 => %w(a b d f g),
    6 => %w(a b d e f g),
    7 => %w(a c f),
    8 => %w(a b c d e f g),
    9 => %w(a b c d f g)
  }

  KNOWN_DIGITS_BY_LENGTH = {
    2 => 1,
    4 => 4,
    3 => 7,
    7 => 8,
  }

  module FirstAndOnly
    refine Array do
      def first_and_only!
        if length != 1
          raise "Expected exactly 1 entry, got #{length}: #{self}"
        else
          first
        end
      end
    end
  end

  def self.from_file_location(file_location)
    entries = File.read(file_location).lines.map(&:strip).map do |line|
      input, output = line.split(" | ")

      inputs = input.split(" ").map do |word|
        word.chars.to_set
      end

      outputs = output.split(" ").map do |word|
        word.chars.to_set
      end

      Entry.new(inputs: inputs, outputs: outputs)
    end

    new(entries: entries)
  end

  class Entry
    using FirstAndOnly

    def initialize(inputs:, outputs:)
      @inputs = inputs
      @outputs = outputs
    end

    def decoded_output_value
      categorized_inputs = [
        LocateSix,
        LocateZeroAndTwo,
        LocateThreeAndFive,
        LocateNine
      ].reduce(UniquelyIdentifiableInputs.new.call(@inputs)) do |knowns, locator|
        locator.new(knowns).call(@inputs)
      end.to_a

      @outputs.map do |output|
        categorized_inputs.select do |number, encoded_number|
          encoded_number == output
        end.first_and_only!.first
      end.join("").to_i
    end

    attr_reader :outputs
  end

  class UniquelyIdentifiableInputs
    def call(inputs)
      inputs.each_with_object({}) do |input, mapping|
        maybe_digit = KNOWN_DIGITS_BY_LENGTH[input.length]

        maybe_digit && mapping[maybe_digit] = input
      end
    end
  end

  class LocateSix
    using FirstAndOnly
    # 6 union 1 => 8 (i.e. find 6 by looking for the unknown number which, when unioned with 1, equals 8)

    def initialize(knowns)
      @knowns = knowns
    end

    def call(inputs)
      known_values = @knowns.values

      unknowns = inputs.reject do |input|
        known_values.include?(input)
      end

      one = @knowns.fetch(1)
      eight = @knowns.fetch(8)

      six = unknowns.select do |unknown|
        unknown.union(one) == eight
      end.first_and_only!

      @knowns.merge(6 => six)
    end
  end

  class LocateZeroAndTwo
    # 4 union 0 => 8
    # 2 union 4 => 8
    # distinguish by size
    def initialize(knowns)
      @knowns = knowns
    end

    def call(inputs)
      known_values = @knowns.values

      unknowns = inputs.reject do |input|
        known_values.include?(input)
      end

      four = @knowns.fetch(4)
      eight = @knowns.fetch(8)

      two, zero = unknowns.select do |unknown|
        unknown.union(four) == eight
      end.sort_by(&:length)

      @knowns.merge(0 => zero, 2 => two)
    end
  end

  class LocateThreeAndFive
    def initialize(knowns)
      @knowns = knowns
    end

    def call(inputs)
      known_values = @knowns.values

      unknowns = inputs.reject do |input|
        known_values.include?(input)
      end.select do |input|
        input.length == 5
      end

      one = @knowns.fetch(1)

      three, five = unknowns.sort_by do |unknown|
        unknown.difference(one).length
      end

      @knowns.merge(3 => three, 5 => five)
    end
  end

  class LocateNine
    using FirstAndOnly

    def initialize(knowns)
      @knowns = knowns
    end

    def call(inputs)
      known_values = @knowns.values

      nine = inputs.reject do |input|
        known_values.include?(input)
      end.first_and_only!

      @knowns.merge(9 => nine)
    end
  end

  def initialize(entries:)
    @entries = entries
  end

  def first_solution
    relevant_encoding_lengths = DIGIT_ENCODINGS.slice(1, 4, 7, 8).values.map(&:length).to_set

    @entries.sum do |entry|
      entry.outputs.count do |output|
        relevant_encoding_lengths.include?(output.length)
      end
    end
  end

  def second_solution
    @entries.sum(&:decoded_output_value)
  end
end
