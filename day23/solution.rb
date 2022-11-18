class Solution

    def initialize(data = "")
        @instructions = read_instructions(data.split("\n"))
    end

    def solution1
        registers = run_assembunny(@instructions, registers: { "a" => 7, "b" => 0, "c" => 0, "d" => 0 })

        puts "========================"
        puts registers
        puts "========================"
        puts "Solution #1: #{registers["a"]}"
        puts "========================"
    end

    def solution2
        #registers = run_decompiled_assembunny(@instructions, registers: { "a" => 12, "b" => 0, "c" => 0, "d" => 0 })
        registers = run_optimized_assembunny(@instructions, registers: { "a" => 12, "b" => 0, "c" => 0, "d" => 0 })

        puts "========================"
        puts registers
        puts "========================"
        puts "Solution #2: #{registers["a"]}"
        puts "========================"
    end

    def solution2b
        puts "========================"
        puts "Solution #2: #{get_result(12)}"
        puts "========================"
    end

    ###################################

    Instruction = Struct.new(:type, :param1, :param2) {
        def to_s
            "#{type}: #{param1}, #{param2}"
        end
    }

    @@instruction_type = { copy: "cpy", increase: "inc", decrease: "dec", jump: "jnz", toggle: "tgl" }

    def read_instructions(lines)
        return lines.map { |line|
            name, param1, param2 = line.split(" ")

            case name
                when @@instruction_type[:copy]
                    value = param1.match(/[a-z]/) ? param1 : Integer(param1)
                    Instruction.new(name, value, param2) # param1 is a register or a number, param2 is a register
                when @@instruction_type[:increase], @@instruction_type[:decrease]
                    Instruction.new(name, param1) # param1 is a register, param2 is undefined
                when @@instruction_type[:jump]
                    value1 = param1.match(/[a-z]/) ? param1 : Integer(param1)
                    value2 = param2.match(/[a-z]/) ? param2 : Integer(param2)
                    Instruction.new(name, value1, value2) # param1 and param2 can both be a register or a number
                when @@instruction_type[:toggle]
                    value = param1.match(/[a-z]/) ? param1 : Integer(param1)
                    Instruction.new(name, value) # param1 is a register or a number, param2 is undefined
            end
        }
    end

    # Original compiled program
    def run_assembunny(instructions, start_idx: 0, registers: { "a" => 0, "b" => 0, "c" => 0, "d" => 0 })
        puts "\nRunning..."

        idx = start_idx
        nb_instructions = 0
        until idx < 0 || idx >= instructions.length
            instruction = instructions[idx]

            nb_instructions += 1
            if nb_instructions % 10000 == 0
                puts "#{nb_instructions} --> #{registers}"
            end

            instruction = instructions[idx]

            case instruction.type
                when @@instruction_type[:copy]
                    # Copy value from source register or initial value
                    registers[instruction.param2] = registers[instruction.param1] || instruction.param1 if registers[instruction.param2]
                when @@instruction_type[:increase]
                    registers[instruction.param1] += 1 if registers[instruction.param1]
                when @@instruction_type[:decrease]
                    registers[instruction.param1] -= 1 if registers[instruction.param1]
                when @@instruction_type[:jump]
                    # If source register value is not zero
                    if (registers[instruction.param1] || instruction.param1) != 0
                        idx += (registers[instruction.param2] || instruction.param2)
                        next
                    end
                when @@instruction_type[:toggle]
                    instruction_idx = idx + (registers[instruction.param1] || instruction.param1)
                    # If affected instruction is inside program
                    if instruction_idx >= 0 && instruction_idx < instructions.length
                        toggle_instruction(instructions[instruction_idx])
                    end
            end

            idx += 1
        end

        puts "\nDone !"

        return registers
    end

    def toggle_instruction(instruction)
        case instruction&.type
            # One param instructions
            when @@instruction_type[:increase]
                instruction.type = @@instruction_type[:decrease]
            when @@instruction_type[:decrease], @@instruction_type[:toggle]
                instruction.type = @@instruction_type[:increase]
            # Two param instructions
            when @@instruction_type[:copy]
                instruction.type = @@instruction_type[:jump]
            when @@instruction_type[:jump]
                instruction.type = @@instruction_type[:copy]
        end
    end

    # Partially decompiled version to analyzed what the code is doing...
    def run_decompiled_assembunny(instructions, registers: { "a" => 0, "b" => 0, "c" => 0, "d" => 0 })
        registers["b"] = registers["a"] # L1
        registers["b"] -= 1 # L2

        loop do
            registers["d"] = registers["a"] # L3
            registers["a"] = 0 # L4

            loop do
                registers["c"] = registers["b"] # L5

                loop do
                    registers["a"] += 1 # L6
                    registers["c"] -= 1 # L7
                    break if registers["c"] == 0 # L8 --> c is now zero
                end

                registers["d"] -= 1 # L9
                break if registers["d"] == 0 # L10 --> d is now zero
            end

            registers["b"] -= 1 # L11
            registers["c"] = registers["b"] # L12
            registers["d"] = registers["c"] # L13

            loop do
                registers["d"] -= 1 # L14
                registers["c"] += 1 # L15
                break if registers["d"] == 0 # L16 --> d is now zero
            end

            # L17 (Toggle instruction)
            instruction_idx = 16 + registers["c"] # c is always positive by this point...
            if instruction_idx < 26 # L27 which does not exists
                toggle_instruction(instructions[instruction_idx])
            end
            puts "#{instruction_idx} --> #{registers}"

            registers["c"] = -16 # L18 --> returning to L3 from L19 unless...
            break if instructions[18].type != @@instruction_type[:jump] # L19 is now a copy instruction instead of jump
        end

        ##
        # Running rest of compiled program because instructions would have changed based on initial "a" register value
        # (since c & d are always zero or positives by this point, we can't jump back again to previous instructions...)
        ##
        return run_assembunny(instructions, start_idx: 18, registers: registers) # Continuing from current line L19
    end

    # Optimized faster version of the above program, fully decompiled with addition loops converted to single multiplication operation
    def run_optimized_assembunny(instructions, registers: { "a" => 0, "b" => 0, "c" => 0, "d" => 0 })
        registers["b"] = registers["a"] # L1
        registers["b"] -= 1 # L2

        loop do
            # L3-L16
            registers["a"] *= registers["b"]
            registers["b"] -= 1 # L11
            registers["c"] = 2 * registers["b"]
            registers["d"] = 0

            # L17 (Toggle instruction: can only toggle odd numbered lines L25 --> L23 --> L21 --> L19 in decreasing order since c is always a multiple of 2)
            instruction_idx = 16 + registers["c"] # c is always positive by this point...
            if instruction_idx < 26 # L27 which does not exists
                toggle_instruction(instructions[instruction_idx])
            end
            puts "#{instruction_idx} --> #{registers}"

            registers["c"] = -16 # L18
            break if instructions[18].type != @@instruction_type[:jump] # L19 (jump)
        end

        ##
        # If initial value of "a" was too small, L25, would not be toggled and we would get an infinite loop because of L26 (jump)
        #
        # note: initial value for "a" must be greater than 5 to not have an infinite loop in original version...
        #       ...the optimized decompiled code below would not give an error, but it would give a different result, so we raise an exception instead
        ##
        raise ArgumentError.new("Invalid initial value for register a") if instructions[24].type != @@instruction_type[:decrease]

        # L19 (copy), L20, L21 (copy), L22, L23 (dec), L24, L25 (dec), L26
        registers["a"] += 88 * 75
        registers["d"] = 0
        registers["c"] = 0

        return registers
    end

    ##
    # Calculate the result directly from what the program is really computing --> n! + 6600
    # This also avoid infinite loop bug when n is lower than 6, so we can cover any integer values of n
    ##
    def get_result(n)
        raise ArgumentError("n must be an integer") if !n.is_a? Integer

        n_factorial = (1..n.abs).reduce(1, :*)
        value = n_factorial + 88 * 75 # 6600

        return n >= 0 ? value : -value
    end

end