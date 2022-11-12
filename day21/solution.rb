class Solution

    def initialize(data = "")
        @operations = data.split("\n")
    end

    def solution1
        password = "abcdefgh"
        scramble_password = encode_password(password)

        puts "========================"
        puts "Solution #1: #{password} --> #{scramble_password}"
        puts "========================"
    end

    def solution2
        scramble_password = "fbgdceah"
        password = decode_password(scramble_password)

        puts "========================"
        puts "Solution #2: #{scramble_password} --> #{password}"
        puts "========================"
    end

    ##################################

    @@operation_regex = {
        :swap_position => /swap position (\d+) with position (\d+)/,
        :swap_letter => /swap letter (\w) with letter (\w)/,
        :reverse_positions => /reverse positions (\d+) through (\d+)/,
        :rotate_left => /rotate left (\d+) step/,
        :rotate_right => /rotate right (\d+) step/,
        :move_position => /move position (\d+) to position (\d+)/,
        :rotate_based => /rotate based on position of letter (\w)/
    }

    @@operations_map = {
        :swap_position => lambda { |s, x, y|
            letter = s[x]
            s[x] = s[y]
            s[y] = letter
            s
        },
        :swap_letter => lambda { |s, a, b|
            idx_a = s.index(a)
            idx_b = s.index(b)
            @@operations_map[:swap_position].call(s, idx_a, idx_b)
        },
        :reverse_positions => lambda { |s, x, y|
            new_s = s[x..y].reverse + s[y+1..]
            x == 0 ? new_s : s[0..x-1] + new_s
        },
        :rotate_left => lambda { |s, n|
            s.each_char.map.with_index { |_, idx| s[(idx + n) % s.length] }.join("")
        },
        :rotate_right => lambda { |s, n|
            @@operations_map[:rotate_left].call(s, -n)
        },
        :move_position => lambda { |s, x, y|
            new_s = s[0..-1]
            new_s[x] = " "
            new_s[y] = x > y ? s[x] + s[y] : s[y] + s[x]
            new_s.tr(" ", "")
        },
        :rotate_based => lambda { |s, a|
            idx_a = s.index(a)
            n = idx_a >= 4 ? 2 + idx_a : 1 + idx_a
            @@operations_map[:rotate_right].call(s, n)
        },
        :reverse_rotate_based => lambda { |s, a|
            # Map of original index to new index after modulo rotation
            rotation_map = (1..s.length).to_a.map.with_index { |n, idx| (idx + (idx >= 4 ? (n + 1) : n)) % s.length }
            idx_a = s.index(a) # Current index after rotation
            reverse_idx_a = rotation_map.index(idx_a) # Original index before rotation
            if idx_a > reverse_idx_a
                @@operations_map[:rotate_left].call(s, idx_a - reverse_idx_a)
            else
                @@operations_map[:rotate_right].call(s, reverse_idx_a - idx_a)
            end
        }
    }

    def encode_password(password, log_operations: true)
        @operations.each do |line|
            print line.ljust(40) if log_operations
            case line
                when @@operation_regex[:swap_position]
                    x, y = line.match(@@operation_regex[:swap_position]).captures
                    password = @@operations_map[:swap_position].call(password, Integer(x), Integer(y))
                when @@operation_regex[:swap_letter]
                    a, b = line.match(@@operation_regex[:swap_letter]).captures
                    password = @@operations_map[:swap_letter].call(password, a, b)
                when @@operation_regex[:reverse_positions]
                    x, y = line.match(@@operation_regex[:reverse_positions]).captures
                    password = @@operations_map[:reverse_positions].call(password, Integer(x), Integer(y))
                when @@operation_regex[:rotate_left]
                    n = line.match(@@operation_regex[:rotate_left]).captures.first
                    password = @@operations_map[:rotate_left].call(password, Integer(n))
                when @@operation_regex[:rotate_right]
                    n = line.match(@@operation_regex[:rotate_right]).captures.first
                    password = @@operations_map[:rotate_right].call(password, Integer(n))
                when @@operation_regex[:move_position]
                    x, y = line.match(@@operation_regex[:move_position]).captures
                    password = @@operations_map[:move_position].call(password, Integer(x), Integer(y))
                when @@operation_regex[:rotate_based]
                    a = line.match(@@operation_regex[:rotate_based]).captures.first
                    password = @@operations_map[:rotate_based].call(password, a)
            end
            puts " --> #{password}" if log_operations
        end
        password
    end

    def decode_password(password, log_operations: true)
        @operations.reverse.each do |line|
            print line.ljust(40) if log_operations
            case line
                when @@operation_regex[:swap_position] # Symmetrical
                    x, y = line.match(@@operation_regex[:swap_position]).captures
                    password = @@operations_map[:swap_position].call(password, Integer(x), Integer(y))
                when @@operation_regex[:swap_letter] # Symmetrical
                    a, b = line.match(@@operation_regex[:swap_letter]).captures
                    password = @@operations_map[:swap_letter].call(password, a, b)
                when @@operation_regex[:reverse_positions] # Symmetrical
                    x, y = line.match(@@operation_regex[:reverse_positions]).captures
                    password = @@operations_map[:reverse_positions].call(password, Integer(x), Integer(y))
                when @@operation_regex[:rotate_left] # Mirrored
                    n = line.match(@@operation_regex[:rotate_left]).captures.first
                    password = @@operations_map[:rotate_right].call(password, Integer(n))
                when @@operation_regex[:rotate_right] # Mirrored
                    n = line.match(@@operation_regex[:rotate_right]).captures.first
                    password = @@operations_map[:rotate_left].call(password, Integer(n))
                when @@operation_regex[:move_position] # Symmetrical
                    x, y = line.match(@@operation_regex[:move_position]).captures
                    password = @@operations_map[:move_position].call(password, Integer(y), Integer(x))
                when @@operation_regex[:rotate_based] # Reversed
                    a = line.match(@@operation_regex[:rotate_based]).captures.first
                    password = @@operations_map[:reverse_rotate_based].call(password, a)
            end
            puts " --> #{password}" if log_operations
        end
        password
    end

end