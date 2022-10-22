############################################

class Solution
    def solution1(data: "")
        puts "========================"
        puts "Solution #1: #{nil}"
        puts "========================"
    end

    def solution2(data: "")
        puts "========================"
        puts "Solution #1: #{nil}"
        puts "========================"
    end
end

############################################

# Reading args
solutionNumber, *args = ARGV

# Reading input
data = File.read("input.txt")

# Running solution
Solution.new.public_send("solution#{solutionNumber}")