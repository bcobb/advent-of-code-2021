class Day14
  def self.from_file_location(file_location)
    template, rules_paragraph = File.read(file_location).split(/\n{2}/)

    rules = rules_paragraph.lines.map(&:strip).to_h do |line|
      pattern, insertion = line.split(" -> ")

      [pattern.chars, insertion]
    end

    new(template: template.chars, rules: rules)
  end

  class InsertionProcess
    def initialize(rules:, template:)
      @rules = rules
      @stats = template.group_by(&:itself).transform_values(&:length)
      @pairs = template.each_cons(2).group_by(&:itself).transform_values(&:length)
    end

    attr_reader :rules, :stats, :pairs

    def run
      next_pairs = @pairs.each_with_object({}) do |(pair, quantity), wip_next_pairs|
        insertion = @rules.fetch(pair)
        first_new_pair = [pair[0], insertion]
        second_new_pair = [insertion, pair[1]]

        @stats[insertion] ||= 0
        wip_next_pairs[first_new_pair] ||= 0
        wip_next_pairs[second_new_pair] ||= 0

        wip_next_pairs[first_new_pair] += quantity
        wip_next_pairs[second_new_pair] += quantity
        @stats[insertion] += quantity
      end

      @pairs = next_pairs
    end

    def max_quantity
      @stats.values.max
    end

    def min_quantity
      @stats.values.min
    end
  end

  def initialize(template:, rules:)
    @template = template
    @rules = rules
  end

  def first_solution
    process = InsertionProcess.new(rules: @rules, template: @template)
    10.times { process.run }

    process.max_quantity - process.min_quantity
  end

  def second_solution
    process = InsertionProcess.new(rules: @rules, template: @template)
    40.times { process.run }

    process.max_quantity - process.min_quantity
  end
end
