class Solution

    def initialize(data = "")
        @instructions = read_instructions(data.split("\n"))
    end

    def solution1
        registers = run_program(@instructions)

        puts "========================"
        puts registers
        puts "========================"
        puts "Solution #1: #{registers["a"]}"
        puts "========================"
    end

    def solution2
        registers = run_program(@instructions, registers: { "a" => 0, "b" => 0, "c" => 1, "d" => 0 })

        puts "========================"
        puts registers
        puts "========================"
        puts "Solution #2: #{registers["a"]}"
        puts "========================"
    end

    ###################################

    Instruction = Struct.new(:type, :param1, :param2)

    @@instruction_type = { "cpy" => :copy, "inc" => :increase, "dec" => :decrease, "jnz" => :jump }

    def read_instructions(lines)
        return lines.map { |line|
            name, param1, param2 = line.split(" ")
            type = @@instruction_type[name]

            case type
                when :copy
                    value = param1.match(/[a-z]/) ? param1 : Integer(param1)
                    Instruction.new(type, value, param2) # param1 is a register or a number, param2 is a register
                when :increase, :decrease
                    Instruction.new(type, param1) # param1 is a register, param2 is undefined
                when :jump
                    value1 = param1.match(/[a-z]/) ? param1 : Integer(param1)
                    value2 = param2.match(/[a-z]/) ? param2 : Integer(param2)
                    Instruction.new(type, value1, value2) # param1 and param2 can both be a register or a number
            end
        }
    end

    def run_program(instructions, registers: { "a" => 0, "b" => 0, "c" => 0, "d" => 0 })
        puts "\nRunning..."

        idx = 0
        nb_instructions = 0
        until idx < 0 || idx >= instructions.length
            instruction = instructions[idx]

            nb_instructions += 1
            if nb_instructions % 100000 == 0
                puts "#{nb_instructions} --> #{registers}"
            end

            instruction = instructions[idx]

            case instruction.type
                when :copy
                    # Copy value from source register or initial value
                    registers[instruction.param2] = registers[instruction.param1] || instruction.param1
                when :increase
                    registers[instruction.param1] += 1
                when :decrease
                    registers[instruction.param1] -= 1
                when :jump
                    # If source register value is not zero
                    if (registers[instruction.param1] || instruction.param1) != 0
                        idx += (registers[instruction.param2] || instruction.param2)
                        next
                    end
            end

            idx += 1
        end

        puts "\nDone !"

        return registers
    end

end