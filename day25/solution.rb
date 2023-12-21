require 'stringio'
require_relative "../lib/assembunny"

class Solution

    def initialize(data = "")
        @program_data = data
    end

    def solution1
        output_stream = StringIO.new
        input_value = 0
        expected_output = 0

        program = Assembunny.new(@program_data, initial_state: { a: input_value })

        loop do
            output_value = program.run
            output_stream << output_value

            if output_value != expected_output
                # Reset clock signal with new input value
                puts "#{input_value} --> #{output_stream.string.split("").join(", ")}, ..."
                output_stream.rewind
                input_value += 1
                expected_output = 0

                program.reset(state: { a: input_value })
                next
            end

            # Clock signal is correct for at least the first 100 values (should be enough ?)
            break if output_stream.size > 100 # In fact 10 is enough to get the right answer for given input...

            # Changing next output value
            expected_output = expected_output == 0 ? 1 : 0
        end

        puts "========================"
        puts "#{output_stream.string.split("").join(", ")}, ..."
        puts "========================"
        puts "Solution #1: #{input_value}"
        puts "========================"
    end

end