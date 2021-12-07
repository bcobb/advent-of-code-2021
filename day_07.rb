class Day07
  def self.from_file_location(file_location)
    new(positions: File.read(file_location).split(",").map { |n| Integer(n) })
  end

  class Fleet
    def initialize(positions:, fuel_cost_calculator:)
      @initial_positions = positions
      @fuel_cost_calculator = fuel_cost_calculator
    end

    def cost_to_align_to(final_position)
      @initial_positions.sum do |position|
        @fuel_cost_calculator.cost_of_moving(initial_position: position, final_position: final_position)
      end
    end
  end

  class ConstantFuelCostCalculator
    def cost_of_moving(initial_position:, final_position:)
      (final_position - initial_position).abs
    end
  end

  class IncreasingFuelCostCalculator
    def cost_of_moving(initial_position:, final_position:)
      n = (final_position - initial_position).abs

      (n * (n + 1)) / 2
    end
  end

  def initialize(positions:)
    @positions = positions
  end

  def first_solution
    fleet = Fleet.new(positions: @positions, fuel_cost_calculator: ConstantFuelCostCalculator.new)

    (@positions.min..@positions.max).map do |final_position|
      fleet.cost_to_align_to(final_position)
    end.min
  end

  def second_solution
    fleet = Fleet.new(positions: @positions, fuel_cost_calculator: IncreasingFuelCostCalculator.new)

    (@positions.min..@positions.max).map do |final_position|
      fleet.cost_to_align_to(final_position)
    end.min
  end
end
