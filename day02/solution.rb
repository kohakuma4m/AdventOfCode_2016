require 'set'

class Solution

    def initialize(data = "")
        @lines = data.split("\n")
    end

    def solution1
        number = 5
        code = ""
        @lines.each do |line|
            line.split("").each do |c|
                number = @@next_keypad_number_map[c].call(number)
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
                number = @@next_hex_keypad_number_map[c].call(number)
            end
            code += number.to_s(16).upcase # Converting to hexadecimal representation
        end

        puts "========================"
        puts "Solution #2: #{code}"
        puts "========================"
    end

    ###################################
    private
    ###################################
    @@key = { up: "U", right: "R", down: "D", left: "L" }

    # Normal keypad 1-9
    @@next_keypad_number_map = {
        @@key[:up] => lambda { |n| n < 4 ? n : n - 3 },
        @@key[:down] => lambda { |n| n > 6 ? n : n + 3 },
        @@key[:left] => lambda { |n| [1, 4, 7].include?(n) ? n : n - 1 },
        @@key[:right] => lambda { |n| [3, 6, 9].include?(n) ? n : n + 1 }
    }

    # Custom hexadecimal keypad 1-D
    @@next_hex_keypad_number_map = {
        @@key[:up] => lambda { |n|
            case n.to_s(16).upcase
                when /[52149]/
                    n
                when /[3D]/
                    n - 2
                else
                    n - 4
            end
        },
        @@key[:down] => lambda { |n|
            case n.to_s(16).upcase
                when /[5ADC9]/
                    n
                when /[1B]/
                    n + 2
                else
                    n + 4
            end
        },
        @@key[:left] => lambda { |n| n.to_s(16).upcase =~ /[125AD]/ ? n : n - 1 },
        @@key[:right] => lambda { |n| n.to_s(16).upcase =~ /[149CD]/ ? n : n + 1 }
    }

end