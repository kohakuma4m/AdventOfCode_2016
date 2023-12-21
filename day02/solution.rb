require "set"

class Solution

    def initialize(data = "")
        @lines = data.split("\n")
    end

    def solution1
        number = 5
        code = ""
        @lines.each do |line|
            line.split("").each do |c|
                key = @@key[c]
                number = @@next_keypad_number_map[key].call(number)
            end
            code += number.to_s
        end

        puts "========================"
        puts "Solution #1: #{code}"
        puts "========================"
    end

    def solution2
        number = 5
        code = ""
        @lines.each do |line|
            line.split("").each do |c|
                key = @@key[c]
                number = @@next_hex_keypad_number_map[key].call(number)
            end
            code += number.to_s(16).upcase # Converting to hexadecimal representation
        end

        puts "========================"
        puts "Solution #2: #{code}"
        puts "========================"
    end

    ###################################

    @@key = { "U" => :up, "R" => :right, "D" => :down, "L" => :left }

    # Normal keypad 1-9
    @@next_keypad_number_map = {
        :up => lambda { |n| n < 4 ? n : n - 3 },
        :down => lambda { |n| n > 6 ? n : n + 3 },
        :left => lambda { |n| [1, 4, 7].include?(n) ? n : n - 1 },
        :right => lambda { |n| [3, 6, 9].include?(n) ? n : n + 1 }
    }

    # Custom hexadecimal keypad 1-D
    @@next_hex_keypad_number_map = {
        :up => lambda { |n|
            case n.to_s(16).upcase
                when /[52149]/
                    n
                when /[3D]/
                    n - 2
                else
                    n - 4
            end
        },
        :down => lambda { |n|
            case n.to_s(16).upcase
                when /[5ADC9]/
                    n
                when /[1B]/
                    n + 2
                else
                    n + 4
            end
        },
        :left => lambda { |n| n.to_s(16).upcase =~ /[125AD]/ ? n : n - 1 },
        :right => lambda { |n| n.to_s(16).upcase =~ /[149CD]/ ? n : n + 1 }
    }

end