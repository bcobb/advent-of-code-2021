class Day12
  def self.from_file_location(file_location)
    connections = File.read(file_location).lines.map(&:strip).map do |line|
      left, right = line.split("-").map { |label| Cave.new(label: label) }

      Connection.new(left: left, right: right)
    end

    new(connections: connections)
  end

  class Cave
    def initialize(label:)
      @label = label
      @hash = self.class.hash ^ { label: @label }.hash
    end

    attr_reader :hash
    attr_reader :label

    def first?
      @label == "start"
    end

    def last?
      @label == "end"
    end

    def big?
      @label.match(/^[A-Z]{1,2}$/)
    end

    def small?
      @label.match(/^[a-z]{1,2}$/)
    end

    def ==(other)
      eql?(other)
    end

    def eql?(other)
      other.class == self.class && other.label == label
    end
  end

  class Connection
    def initialize(left:, right:)
      @left = left
      @right = right
    end

    def caves
      [left, right]
    end

    def last_step?
      @right.last? || @left.last?
    end

    def predecessor_to(cave)
      case cave
      when left
        right
      when right
        left
      end
    end

    attr_reader :left
    attr_reader :right
  end

  class Path
    def initialize(progress:, repeat_visit_rule:)
      @progress = progress
      @repeat_visit_rule = repeat_visit_rule
      @hash = progress.map(&:hash).reduce(&:^)
    end

    attr_reader :hash
    attr_reader :progress

    def complete?
      @progress.any?(&:first?)
    end

    def search(connections)
      current_cave = @progress.last

      connections.each_with_object([]) do |connection, previous_caves|
        maybe_predecessor = connection.predecessor_to(current_cave)

        maybe_predecessor && previous_caves << maybe_predecessor
      end.select do |previous_cave|
        @repeat_visit_rule.allows_visiting?(cave: previous_cave, progress: @progress)
      end.map do |previous_cave|
        Path.new(progress: @progress + [previous_cave], repeat_visit_rule: @repeat_visit_rule)
      end
    end

    def join(separator = nil)
      @progress.map(&:label).reverse.join(separator)
    end

    def eql?(other)
      other.class == Path && other.progress == progress
    end

    def ==(other)
      eql?(other)
    end
  end

  class Map
    def initialize(connections:, repeat_visit_rules:)
      @connections = connections
      @repeat_visit_rules = repeat_visit_rules
    end

    def complete_paths
      Enumerator.new do |e|
        queue = @connections.select(&:last_step?).flat_map do |connection|
          if connection.right.last?
            progress = [connection.right, connection.left]
          else
            progress = [connection.left, connection.right]
          end

          @repeat_visit_rules.map do |repeat_visit_rule|
            Path.new(progress: progress, repeat_visit_rule: repeat_visit_rule)
          end
        end

        while queue.any?
          path = queue.shift

          possible_next_paths = path.search(@connections)

          complete_paths, incomplete_paths = possible_next_paths.partition(&:complete?)

          complete_paths.each do |path|
            e << path
          end

          queue += incomplete_paths
        end
      end
    end
  end

  class LimitSmallCaveVisitsToOne
    def allows_visiting?(cave:, progress:)
      cave.big? ||
      (cave.small? && !progress.include?(cave)) ||
      cave.first?
    end
  end

  class AllowVisitingOneSmallCaveTwice
    def initialize(special_cave:)
      @special_cave = special_cave
    end

    def allows_visiting?(cave:, progress:)
      if cave.small?
        visit_limit = cave == @special_cave ? 2 : 1

        progress.count { |visited_cave| visited_cave == cave } < visit_limit
      else
        cave.big? || cave.first?
      end
    end
  end

  def initialize(connections:)
    @connections = connections
  end

  def first_solution
    map = Map.new(connections: @connections, repeat_visit_rules: [LimitSmallCaveVisitsToOne.new])

    map.complete_paths.count
  end

  def second_solution
    small_caves = @connections.flat_map(&:caves).uniq.select(&:small?)
    repeat_visit_rules = small_caves.map do |small_cave|
      AllowVisitingOneSmallCaveTwice.new(special_cave: small_cave)
    end

    map = Map.new(connections: @connections, repeat_visit_rules: repeat_visit_rules)

    map.complete_paths.uniq.count
  end
end
