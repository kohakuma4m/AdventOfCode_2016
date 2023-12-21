class Solution

    def initialize(data = "")
        @max_ip_value = 2**32 - 1
        @ip_ranges = data.split("\n")
            .map { |s| s.split("-").map { |n| Integer(n) } }
            .sort_by { |(min, max)| min }
    end

    ##
    # Finding first whitelisted ip
    ##
    def solution1
        n = 0
        previous_max = 0
        @ip_ranges.each do |(min, max)|
            break if min > n

            if n == min || min <= [n, previous_max].max
                n = max + 1 unless max < previous_max || n > max + 1
            end

            previous_max = max
        end

        # No whitelisted ip found
        n = nil if n > @max_ip_value

        puts "========================"
        puts "Solution #1: #{n}"
        puts "========================"
    end

    ##
    # Finding all whitelisted ip ranges
    ##
    def solution2
        whitelisted_ip_ranges = []

        n = 0
        previous_max = 0
        @ip_ranges.each do |(min, max)|
            if n < min
                whitelisted_ip_ranges << [n, min - 1]
                n = min
            end

            if n == min || min <= [n, previous_max].max
                n = max + 1 unless max < previous_max || n > max + 1
            end

            previous_max = max
        end

        whitelisted_ip_ranges << [n, @max_ip_value] unless n > @max_ip_value

        # Counting number of whitelisted ips
        nb_whitelisted_ips = whitelisted_ip_ranges.map { |(min, max)| max - min + 1 }.sum

        puts "========================"
        whitelisted_ip_ranges.each.with_index { |(min, max), idx|
            puts "##{(idx + 1).to_s.ljust(3)} --> [#{max > min ? "#{min}-#{max}" : "#{min}"}]"
        }
        puts "========================"
        puts "Solution #2c: #{nb_whitelisted_ips}"
        puts "========================"
    end

end