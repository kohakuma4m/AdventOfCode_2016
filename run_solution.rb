require "benchmark"

# Reading args
folder, solution_number, *args = ARGV

# Running day folder solution
require_relative "#{folder}/solution"

Dir.chdir("#{folder}") do
    # Reading input
    data = File.read("input.txt")

    # Running solution
    solution = Solution.new(data)
    solution_method = "solution#{solution_number}"
    if solution.respond_to?(solution_method)
        puts Benchmark.realtime {
            solution.public_send(solution_method)
        }
    end
end