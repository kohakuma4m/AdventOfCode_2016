require_relative "../lib/assembunny"

class Solution

    def initialize(data = "")
        @program_data = data
    end

    def solution1
        program = Assembunny.new(@program_data)
        program.run

        puts "========================"
        puts program.state.registers
        puts "========================"
        puts "Solution #1: #{program.state.registers[:a]}"
        puts "========================"
    end

    def solution2
        program = Assembunny.new(@program_data, initial_state: { c: 1 })
        program.run(log: true)

        puts "========================"
        puts program.state.registers
        puts "========================"
        puts "Solution #2: #{program.state.registers[:a]}"
        puts "========================"
    end

end