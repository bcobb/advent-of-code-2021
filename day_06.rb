class Day06
  def self.from_file_location(file_location)
    timers = File.read(file_location).strip.split(",").map do |number|
      Integer(number)
    end

    new(timers: timers)
  end

  class Simulation
    def initialize(timers:)
      @timers = timers.group_by(&:itself).transform_values(&:length)
    end

    def tick
      new_timers = {}

      @timers.each do |timer, quantity|
        if timer == 0
          new_timers[8] = quantity
          new_timers[6] ||= 0
          new_timers[6] += quantity
        else
          new_timers[timer - 1] ||= 0
          new_timers[timer - 1] += quantity
        end
      end

      @timers = new_timers

      self
    end

    def total_fish
      @timers.values.sum
    end
  end

  def initialize(timers:)
    @initial_timers = timers
  end

  def first_solution
    simulation = Simulation.new(timers: @initial_timers)

    80.times { simulation.tick }

    simulation.total_fish
  end

  def second_solution
    simulation = Simulation.new(timers: @initial_timers)

    256.times { simulation.tick }

    simulation.total_fish
  end
end
