require_relative "../lib/grid"

class Solution

    def initialize(data = "")
        @operations = read_instructions(data)
    end

    def solution1
        grid = Grid.new(50, 6, LIGHTS[:off])
        fill_grid(grid)

        nb_lights = grid.data.sum(0) { |row| row.sum(0) { |s| (s == LIGHTS[:on] ? 1 : 0) } }

        puts "========================"
        puts "Solution #1: #{nb_lights}"
        puts "========================"
    end

    def solution2
        grid = Grid.new(50, 6, LIGHTS[:off])
        fill_grid(grid)

        puts "========================"
        puts "Solution #2:"
        grid.print
        puts "========================"
    end

    ###################################

    LIGHTS = { on: "#", off: "." }

    Operation = Struct.new(:instruction, :value1, :value2)

    INSTRUCTIONS_REGEX = /(rect|rotate row|rotate column) (?:(\d+)x(\d+)|[xy]=(\d+) by (\d+))/

    def read_instructions(data)
        return data.split("\n").map do |line|
            instruction, val1, val2 = line.match(INSTRUCTIONS_REGEX).captures.compact # Removing nil values
            Operation.new(instruction, Integer(val1), Integer(val2))
        end
    end

    def fill_grid(grid)
        @operations.each do |operation|
            case operation.instruction
                when "rect"
                    dx, dy = [operation.value1, operation.value2]
                    dy.times { |y| dx.times { |x| grid.data[y][x] = LIGHTS[:on] } }
                when "rotate column"
                    col, dy = [operation.value1, operation.value2]
                    rotated_column = grid.data.transpose[col].rotate!(-dy)
                    grid.height.times { |y| grid.data[y][col] = rotated_column[y] }
                when "rotate row"
                    row, dx = [operation.value1, operation.value2]
                    grid.data[row].rotate!(-dx)
            end
        end
    end

end