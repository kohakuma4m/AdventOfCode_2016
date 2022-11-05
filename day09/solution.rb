class Solution

    def initialize(data = "")
        @data = data
    end

    def solution1
        data = decompress_data(@data)

        puts "========================"
        puts "Compression: #{(100.0 * @data.length / data.length).round(6)}%"
        puts "========================"
        puts "Solution #1: #{data.length}"
        puts "========================"
    end

    def solution2
        #length = get_decompressed_data_length_old(@data)
        length = get_decompressed_data_length(@data)

        puts "========================"
        puts "Compression: #{(100.0 * @data.length / length).round(6)}%"
        puts "========================"
        puts "Solution #2: #{length}"
        puts "========================"
    end

    ###################################

    ##
    # Real decompression solution for part 1
    #
    # Assumptions
    # 1) All markers are closed (i.e: no orphan parenthesis)
    # 2) No marker affected characters outside string
    ##
    def decompress_data(compress_data)
        data = ""

        i = 0
        until i >= compress_data.length
            # Normal character
            if compress_data[i] != "("
                data += compress_data[i]
                i += 1
                next
            end

            # Extract marker
            marker = ""
            until compress_data[i + 1] == ")"
                i += 1
                marker += compress_data[i]
            end
            i += 2 # First character after marker

            # Apply marker to repeat x next characters y times
            x, y = marker.split("x").map { |n| Integer(n) }
            pattern = compress_data[i..i + x - 1]
            y.times { |_| data += pattern }
            i += x
        end

        return data
    end

    ##
    # Buffer solution with constant memory utilisation...
    # ...but very computationally intensive (because of assumption #4)
    #
    # Runtime: Almost 2 hours...
    #
    # Assumptions
    # 1) All markers are closed (i.e: no orphan parenthesis)
    # 2) No marker affected characters outside string
    # 3) Assumption #1 remains true after any marker decompression
    # 4) Sub marker could affect characters outside parent marker
    ##
    def get_decompressed_data_length_old(compress_data)
        length = 0
        buffer = compress_data.split("")

        until buffer.length == 0
            c = buffer.shift
            length += 1

            if length % 10000000 == 0
                puts "#{length} <-- #{buffer.length}"
            end

            if c == "("
                length -= 1

                # Extract marker
                marker = ""
                loop do
                    c = buffer.shift

                    if c == ")"
                        break
                    end

                    marker += c
                end

                # Apply marker to repeat x next characters y times
                x, y = marker.split("x").map { |n| Integer(n) }
                pattern = buffer.shift(x)
                buffer.unshift(*(pattern * y))
            end
        end

        return length
    end

    ##
    # Simple & very elegant alternative solution for part 2
    # adapted from here: https://github.com/rhardih/aoc/blob/master/2016/9p2.c
    #
    # In short, we just sum the number of time each normal character is repeated
    # as we read the original data from left to right only once (no recursion)
    #
    # Assumptions
    # 1) All markers are closed (i.e: no orphan parenthesis)
    # 2) No marker affected characters outside string
    # 3) Assumption #1 remains true after any marker decompression
    # 4) Sub marker could affect characters outside parent marker
    ##
    def get_decompressed_data_length(compress_data)
        # Initializing weights
        weights = [1] * compress_data.length

        i = 0
        until i >= compress_data.length
            # Normal character
            if compress_data[i] != "("
                i += 1
                next
            end

            # Extract marker
            marker = ""
            weights[i] = 0
            until compress_data[i + 1] == ")"
                i += 1
                weights[i] = 0
                marker += compress_data[i]
            end
            weights[i + 1] = 0
            i += 2 # First character after marker

            # Multiply weight of all characters affected by marker
            x, y = marker.split("x").map { |n| Integer(n) }
            (i..i + x - 1).each { |j| weights[j] *= y }
        end

        return weights.sum
    end

end