require 'stringio'

class Solution

    def initialize(data = "")
        @instructions = read_instructions(data.split("\n"))
    end

    def solution1
        output_stream = StringIO.new
        input_value = 0
        expected_output = 0

        idx = 0
        nb_instructions = 0
        registers = { "a" => input_value, "b" => 0, "c" => 0, "d" => 0 }
        loop do
            output_value, idx, nb_instructions, registers = generate_next_clock_signal(@instructions, registers: registers, idx: idx, nb_instructions: nb_instructions)
            output_stream << output_value

            if output_value != expected_output
                # Reset clock signal with new input value
                puts "#{input_value} --> #{output_stream.string.split("").join(", ")}"
                output_stream.rewind
                input_value += 1
                expected_output = 0

                idx = 0
                nb_instructions = 0
                registers = { "a" => input_value, "b" => 0, "c" => 0, "d" => 0 }
                next
            end

            # Clock signal is correct for at least the first 100 values (should be enough ?)
            break if output_stream.size > 100 # In fact 10 is enough to get the right answer for given input...

            # Changing next output value
            expected_output = expected_output == 0 ? 1 : 0
        end

        puts "========================"
        puts output_stream.string.split("").join(", ") + ", ..."
        puts "========================"
        puts "Solution #1: #{input_value}"
        puts "========================"
    end

    ###################################

    Instruction = Struct.new(:type, :param1, :param2) {
        def to_s
            "#{type}: #{param1}, #{param2}"
        end
    }

    @@instruction_type = { "cpy" => :copy, "inc" => :increase, "dec" => :decrease, "jnz" => :jump, "tgl" => :toggle, "out" => :transmit }

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
                when :toggle
                    value = param1.match(/[a-z]/) ? param1 : Integer(param1)
                    Instruction.new(type, value) # param1 is a register or a number, param2 is undefined
                when :transmit
                    value = param1.match(/[a-z]/) ? param1 : Integer(param1)
                    Instruction.new(type, value) # param1 is a register or a number, param2 is undefined
            end
        }
    end

    def generate_next_clock_signal(instructions, registers: { "a" => 0, "b" => 0, "c" => 0, "d" => 0 }, idx: 0, nb_instructions: 0)
        until idx < 0 || idx >= instructions.length
            instruction = instructions[idx]
            nb_instructions += 1

            case instruction.type
                when :copy
                    # Copy value from source register or initial value
                    registers[instruction.param2] = registers[instruction.param1] || instruction.param1 if registers[instruction.param2]
                when :increase
                    registers[instruction.param1] += 1 if registers[instruction.param1]
                when :decrease
                    registers[instruction.param1] -= 1 if registers[instruction.param1]
                when :jump
                    # If source register value is not zero
                    if (registers[instruction.param1] || instruction.param1) != 0
                        idx += (registers[instruction.param2] || instruction.param2)
                        next
                    end
                when :toggle
                    instruction_idx = idx + (registers[instruction.param1] || instruction.param1)
                    # If affected instruction is inside program
                    if instruction_idx >= 0 && instruction_idx < instructions.length
                        toggle_instruction(instructions[instruction_idx])
                    end
                when :transmit
                    value = registers[instruction.param1] || instruction.param1
                    return [value, idx + 1, nb_instructions, registers] # Pausing execution so we can validate output and resume execution afterward
            end

            idx += 1
        end

        return registers
    end

    def toggle_instruction(instruction)
        case instruction&.type
            # One param instructions
            when :increase
                instruction.type = :decrease
            when :decrease, :toggle, :transmit
                instruction.type = :increase
            # Two param instructions
            when :copy
                instruction.type = :jump
            when :jump
                instruction.type = :copy
        end
    end

end