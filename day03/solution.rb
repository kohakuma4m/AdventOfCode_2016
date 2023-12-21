class Solution

    def initialize(data = "")
        @tuples = data.split("\n")
            .map { |l| l.split(" ").map { |n| Integer(n) } }
    end

    def solution1
        # Validation
        raise ArgumentError.new("Missing tuple value(s) for at least one row !") if @tuples.find { |t| t.length != 3 }

        # Row triangles
        triangles = @tuples.select(&method(:valid_triangle?))

        puts "========================"
        puts "Solution #1: #{triangles.length}"
        puts "========================"
    end

    def solution2
        # Validation
        raise ArgumentError.new("Missing tuple value(s) for at least one row !") if @tuples.find { |t| t.length != 3 }
        raise ArgumentError.new("Number of rows is not divisible by 3 !") if @tuples.length % 3 != 0

        # Column triangles
        triangles = @tuples.transpose.flatten.each_slice(3).select(&method(:valid_triangle?))

        puts "========================"
        puts "Solution #2: #{triangles.length}"
        puts "========================"
    end

    ###################################

    def valid_triangle?((a, b, c))
        return a + b > c && a + c > b && b + c > a
    end

end