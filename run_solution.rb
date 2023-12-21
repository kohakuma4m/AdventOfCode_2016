require "benchmark"

# Reading args
folder, solution_number, *args = ARGV

# Running day folder solution
require_relative "#{folder}/solution"

Dir.chdir("#{folder}") do
    # Reading input
    data = File.read("input.txt")

    # Running solution
    puts Benchmark.realtime {
        solution = Solution.new(data)
        solution_method = "solution#{solution_number}"
        if solution.respond_to?(solution_method)
            solution.public_send(solution_method)
        end
    }
end