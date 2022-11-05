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

    @@instruction_type = { copy: "cpy", increase: "inc", decrease: "dec", jumps: "jnz" }

    def read_instructions(lines)
        return lines.map { |line|
            name, param1, param2 = line.split(" ")

            case name
                when @@instruction_type[:copy]
                    value = param1.match(/[a-z]/) ? param1 : Integer(param1)
                    Instruction.new(name, value, param2) # param1 is a register or a number, param2 is a register
                when @@instruction_type[:increase], @@instruction_type[:decrease]
                    Instruction.new(name, param1) # param1 is a register
                when @@instruction_type[:jumps]
                    Instruction.new(name, param1, Integer(param2)) # param1 is a register, param2 is a value
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
                when @@instruction_type[:copy]
                    # Copy value from source register or initial value
                    registers[instruction.param2] = registers[instruction.param1] ? registers[instruction.param1] : instruction.param1
                when @@instruction_type[:increase]
                    registers[instruction.param1] += 1
                when @@instruction_type[:decrease]
                    registers[instruction.param1] -= 1
                when @@instruction_type[:jumps]
                    # If source register value is not zero
                    if registers[instruction.param1] != 0
                        idx += instruction.param2
                        next
                    end
            end
            idx += 1
        end

        puts "\nDone !"

        return registers
    end

end