class Solution
    def initialize(data = "")
        @lines = data.split("\n").map { |l| l.split("") }
    end

    def solution1
        # Join most common letter at each position
        message = @lines.transpose.flatten.each_slice(@lines.length)
            .map { |position_chars|
                char_counts = Hash.new(0)
                position_chars.each { |c| char_counts[c] += 1 }
                char_counts.max_by{ |key, value| value }
            }
            .map { |key, value| key }
            .join("")

        puts "========================"
        puts "Solution #1: #{message}"
        puts "========================"
    end

    def solution2
        # Join least common letter at each position
        message = @lines.transpose.flatten.each_slice(@lines.length)
            .map { |position_chars|
                char_counts = Hash.new(0)
                position_chars.each { |c| char_counts[c] += 1 }
                char_counts.min_by{ |key, value| value }
            }
            .map { |key, value| key }
            .join("")

        puts "========================"
        puts "Solution #2: #{message}"
        puts "========================"
    end
end