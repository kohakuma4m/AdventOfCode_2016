require "set"

class Solution

    def initialize(data = "")
        @instructions = data.split(", ")
    end

    def solution1
        position = [0, 0]
        direction = @@direction[:north]

        @instructions.each do |s|
            direction = @@direction_map[direction][s[0]]
            position = @@next_position_map[direction].call(*position, Integer(s[1..]))
        end

        x, y = position
        distance = x.abs + y.abs

        puts "========================"
        puts "#{direction} #{position}"
        puts "========================"
        puts "Solution #1: #{distance}"
        puts "========================"
    end

    def solution2
        position = [0, 0]
        direction = @@direction[:north]

        visited_positions = Set[position]
        @instructions.each do |s|
            direction = @@direction_map[direction][s[0]]
            position, is_already_visited_position = moveToNextPosition(position, direction, Integer(s[1..]), visited_positions)
            if is_already_visited_position
                break
            end
        end

        x, y = position
        distance = x.abs + y.abs

        puts "========================"
        puts "#{direction} #{position}"
        puts "========================"
        puts "Solution #2: #{distance}"
        puts "========================"
    end

    ###################################

    @@direction = { north: "North", east: "East", south: "South", west: "West" }
    @@direction_map = {
        @@direction[:north] => { "R" => @@direction[:east], "L" => @@direction[:west] },
        @@direction[:east] => { "R" => @@direction[:south], "L" => @@direction[:north] },
        @@direction[:south] => { "R" => @@direction[:west], "L" => @@direction[:east] },
        @@direction[:west] => { "R" => @@direction[:north], "L" => @@direction[:south] }
    }
    @@next_position_map = {
        @@direction[:north] => lambda { |x, y, nb_steps| [x, y + nb_steps] },
        @@direction[:east] => lambda { |x, y, nb_steps| [x + nb_steps, y] },
        @@direction[:south] => lambda { |x, y, nb_steps| [x, y - nb_steps] },
        @@direction[:west] => lambda { |x, y, nb_steps| [x - nb_steps, y] }
    }

    def moveToNextPosition(position, direction, nb_steps, visited_positions)
        nb_steps.times do
            position = @@next_position_map[direction].call(*position, 1)
            if !visited_positions.add?(position)
                return [position, true] # Visiting already visiting position
            end
        end

        return [position, false]
    end

end