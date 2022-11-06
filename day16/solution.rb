require 'stringio'

class Solution

    def initialize(data = "")
        @initial_state = data
    end

    def solution1
        data = generate_data(@initial_state, 272)

        checksum = data
        until checksum.length % 2 == 1
            puts checksum.length
            checksum = generate_next_checksum(checksum)
        end

        puts "========================"
        puts "Solution #1: #{checksum}"
        puts "========================"
    end

    def solution2
        data = generate_data(@initial_state, 35651584)

        checksum = data
        while checksum.length % 2 == 0
            puts checksum.length
            checksum = generate_next_checksum_2(checksum)
        end

        puts "========================"
        puts "Solution #2: #{checksum}"
        puts "========================"
    end

    def solution2b
        data = generate_data(@initial_state, 35651584)

        checksum = data
        while checksum.length % 2 == 0
            puts checksum.length
            checksum = generate_next_checksum_3(checksum)
        end

        puts "========================"
        puts "Solution #2b: #{checksum}"
        puts "========================"
    end

    def solution2c
        data = generate_data(@initial_state, 35651584)
        checksum = generate_checksum(data)

        puts "========================"
        puts "Solution #2c: #{checksum}"
        puts "========================"
    end

    ###################################

    def generate_next_state(data)
        "#{data}0#{data.reverse.tr("01", "10")}" # Reverse than flip 1 <--> 0
    end

    # Generating enough data to fill disc
    def generate_data(initial_state, target_length)
        data = initial_state

        until data.length >= target_length
            data = generate_next_state(data)
        end

        return data[..target_length - 1]
    end

    ##
    # Simple functional version
    #
    # Run in about 11 minutes for part 2
    ##
    def generate_next_checksum(data)
        data.split("").each_slice(2)
            .map { |(x, y)| x == y ? "1" : "0" }
            .join("")
    end

    ##
    # Iterative version with pre-memory allocation for checksum
    #
    # Note: string concatenation is far too slow for very large string
    #
    # Run in about 60s for part 2
    ##
    def generate_next_checksum_2(data)
        checksum_length = data.length / 2

        i = 0
        j = 0
        checksum = Array.new(checksum_length)
        while j < checksum_length
            checksum[j] = data[i] == data[i + 1] ? "1": "0"
            i += 2
            j += 1
        end

        return checksum.join("")
    end

    ##
    # Optimized iterative version with String Buffer instead of array
    #
    # Run in about 20s for part 2
    ##
    def generate_next_checksum_3(data)
        checksum_length = data.length / 2

        i = 0
        j = 0
        checksum = StringIO.new
        while j < checksum_length
            checksum << (data[i] == data[i + 1] ? "1": "0")
            i += 2
            j += 1
        end

        return checksum.string
    end

    ##
    # Optimized version which calculate checksum directly in one go
    #
    # 1) Calculate number of steps required to get final checksum with odd length
    # 2) For each chunk of size 2 * nb_steps, count number of "1"
    #    If even, the final checksum digit is "1", otherwise it's "0" as one pair will cancel out everything else in chunk
    #
    #    e.g: 11010100 --> [11, 01, 11, 00] --> 1011 --> [10, 11] --> 01
    #          same as --> [1101, 1100]                           --> 01
    #
    # Run in less than 0.25s for part 2 (even without string buffer since final checksum length is very small)
    ##
    def generate_checksum(data)
        chunk_size = 2
        until (data.length / chunk_size) % 2 == 1
            chunk_size *= 2
        end
        nb_chunks = data.length / chunk_size

        i = 0
        checksum = StringIO.new
        while i < nb_chunks
            j = i * chunk_size
            checksum << (data[j..j + chunk_size - 1].count("1") % 2 == 0 ? "1" : "0")
            i += 1
        end

        return checksum.string
    end

end