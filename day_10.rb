class Day10
  def self.from_file_location(file_location)
    lines = File.read(file_location).lines.map(&:strip)
    completions = lines.map do |line|
      Completion.new(line: line)
    end

    new(completions: completions)
  end

  class Completion
    def initialize(line:)
      @line = line
    end

    def illegal?
      required_additions
    rescue Error
      true
    else
      false
    end

    def score
      required_additions.reduce(0) do |wip_score, addition|
        (wip_score * 5) + SCORES[addition]
      end
    end

    def required_additions
      stack = []

      @line.chars.each do |char|
        case char
        when *PAIRS.keys
          stack.push(char)
        when *PAIRS.values
          opener = stack.pop

          if PAIRS[opener] != char
            raise Error.new(expected: PAIRS[opener], got: char)
          end
        else
          raise "Unknown character #{char}"
        end
      end

      stack.map do |opener|
        PAIRS[opener]
      end.reverse
    end

    PAIRS = {
      '(' => ')',
      '{' => '}',
      '[' => ']',
      '<' => '>',
    }

    SCORES = {
      ')' => 1,
      ']' => 2,
      '}' => 3,
      '>' => 4,
    }

    class Error < StandardError
      def initialize(expected:, got:)
        @expected = expected
        @got = got

        super
      end

      attr_reader :expected
      attr_reader :got

      def to_s
        "Expected #{expected.inspect}, got #{got.inspect}"
      end

      def score
        SCORES[got]
      end

      SCORES = {
        ')' => 3,
        ']' => 57,
        '}' => 1197,
        '>' => 25137,
      }
    end
  end

  def initialize(completions:)
    @completions = completions
  end

  def first_solution
    @completions.sum do |completion|
      begin
        completion.required_additions
      rescue Completion::Error => e
        e.score
      else
        0
      end
    end
  end

  def second_solution
    scores = @completions.reject(&:illegal?).map do |completion|
      completion.score
    end.sort

    scores[scores.length / 2]
  end
end
