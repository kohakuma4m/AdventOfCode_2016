require "set"

class Solution

    def initialize(data = "")
        @instructions = data.split(", ")
    end

    def solution1
        position = [0, 0]
        direction = :north

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
        direction = :north

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

    @@direction_map = {
        :north => { "R" => :east, "L" => :west },
        :east => { "R" => :south, "L" => :north },
        :south => { "R" => :west, "L" => :east },
        :west => { "R" => :north, "L" => :south }
    }
    @@next_position_map = {
        :north => lambda { |x, y, nb_steps| [x, y + nb_steps] },
        :east => lambda { |x, y, nb_steps| [x + nb_steps, y] },
        :south => lambda { |x, y, nb_steps| [x, y - nb_steps] },
        :west => lambda { |x, y, nb_steps| [x - nb_steps, y] }
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