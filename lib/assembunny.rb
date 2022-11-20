class Assembunny

    INSTRUCTIONS_TYPE = {
        "cpy" => :copy,
        "inc" => :increase,
        "dec" => :decrease,
        "jnz" => :jump,
        "tgl" => :toggle,
        "out" => :transmit
    }

    attr_reader :state

    def initialize(program_data, initial_state: {})
        @instructions = Assembunny.read_instructions(program_data)
        @state = State.new(**initial_state)
    end

    def run(log: false)
        nb_instructions = 0

        until @state.instruction_idx < 0 || @state.instruction_idx >= @instructions.length
            # Current instruction to execute
            instruction = @instructions[@state.instruction_idx]

            nb_instructions += 1
            if log && nb_instructions % 1000000 == 0
                puts "#{nb_instructions} --> #{@state.registers}"
            end

            case instruction.type
                when :copy
                    # Copy value from source register or initial value
                    @state.registers[instruction.param2] = @state.registers[instruction.param1] || instruction.param1 if @state.registers[instruction.param2]
                when :increase
                    @state.registers[instruction.param1] += 1 if @state.registers[instruction.param1]
                when :decrease
                    @state.registers[instruction.param1] -= 1 if @state.registers[instruction.param1]
                when :jump
                    # If source register value is not zero
                    if (@state.registers[instruction.param1] || instruction.param1) != 0
                        @state.instruction_idx += (@state.registers[instruction.param2] || instruction.param2)
                        next
                    end
                when :toggle
                    instruction_idx = @state.instruction_idx + (@state.registers[instruction.param1] || instruction.param1)
                    # If affected instruction is inside program
                    if instruction_idx >= 0 && instruction_idx < @instructions.length
                        Assembunny.toggle_instruction(@instructions[instruction_idx])
                    end
                when :transmit
                    value = @state.registers[instruction.param1] || instruction.param1
                    @state.instruction_idx += 1
                    return value # Halting execution... rerunning program will continue with current state, unless reset...
            end

            @state.instruction_idx += 1
        end
    end

    def reset(state: {})
        @state = State.new(**state)
    end

    class Instruction
        attr_reader :param1, :param2
        attr_accessor :type

        def initialize(type, param1 = nil, param2 = nil)
            @type = type
            @param1 = param1
            @param2 = param2
        end

        def to_s
            "#{type}: #{param1}, #{param2}"
        end

    end

    class State

        REGISTERS = { "a" => :a, "b" => :b, "c" => :c, "d" => :d }

        attr_accessor :registers, :instruction_idx

        def initialize(a: 0, b: 0, c: 0 , d: 0)
            @instruction_idx = 0
            @registers = { :a => a, :b => b, :c => c, :d => d }
        end

    end

    ##############################
    public

    def self.read_instructions(program_data)
        return program_data.split("\n").map do |line|
            name, param1, param2 = line.split(" ")
            type = INSTRUCTIONS_TYPE[name]

            case type
                when :copy
                    value = param1.match(/[a-z]/) ? State::REGISTERS[param1] : Integer(param1)
                    Instruction.new(type, value, State::REGISTERS[param2]) # param1 is a register or a number, param2 is a register
                when :increase, :decrease
                    Instruction.new(type, State::REGISTERS[param1]) # param1 is a register, param2 is undefined
                when :jump
                    value1 = param1.match(/[a-z]/) ? State::REGISTERS[param1] : Integer(param1)
                    value2 = param2.match(/[a-z]/) ? State::REGISTERS[param2] : Integer(param2)
                    Instruction.new(type, value1, value2) # param1 and param2 can both be a register or a number
                when :toggle
                    value = param1.match(/[a-z]/) ? State::REGISTERS[param1] : Integer(param1)
                    Instruction.new(type, value) # param1 is a register or a number, param2 is undefined
                when :transmit
                    value = param1.match(/[a-z]/) ? State::REGISTERS[param1] : Integer(param1)
                    Instruction.new(type, value) # param1 is a register or a number, param2 is undefined
            end
        end
    end

    def self.toggle_instruction(instruction)
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