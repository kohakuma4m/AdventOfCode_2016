require "digest"

class Solution

    def initialize(data = "")
        @salt = data
    end

    def solution1
        valid_key_indexes, hashes = generated_keys(64)
        valid_keys = hashes.select.with_index { |_, idx| valid_key_indexes.include?(idx) }

        puts "========================"
        puts valid_keys
        puts "========================"
        puts "Solution #1: #{valid_key_indexes[-1]}"
        puts "========================"
    end

    def solution2
        valid_key_indexes, hashes = generated_keys(64, generation_function: method(:generate_stretched_hash))
        valid_keys = hashes.select.with_index { |_, idx| valid_key_indexes.include?(idx) }

        puts "========================"
        puts valid_keys
        puts "========================"
        puts "Solution #2: #{valid_key_indexes[-1]}"
        puts "========================"
    end

    ###################################

    KEY_REGEX = /(.+)\1\1/

    def generate_hash(salt, n)
        Digest::MD5.hexdigest("#{salt}#{n}").downcase
    end

    def generate_stretched_hash(salt, n)
        h = generate_hash(salt, n)
        2016.times { |_| h = Digest::MD5.hexdigest(h).downcase }
        h
    end

    def is_valid_key?(idx, hashes)
        raise ArgumentError.new("Not enough following hashes to check if key is valid") if hashes.length < idx + 1001

        key_to_validate = hashes[idx]
        repeated_char = key_to_validate.match(KEY_REGEX)&.captures
        if !repeated_char
            return false
        end

        pattern = (repeated_char * 5).join("")
        return !!hashes[idx + 1..idx + 1000].find { |h| h.include?(pattern) }
    end

    def generated_keys(nb_keys, generation_function: method(:generate_hash))
        hashes = 1000.times.map { |n| generation_function.call(@salt, n) }
        valid_key_indexes = []

        until valid_key_indexes.length == nb_keys
            hashes.push(generation_function.call(@salt, hashes.length))

            idx = hashes.length - 1001
            if is_valid_key?(idx, hashes)
                valid_key_indexes.push(idx)
                puts "##{valid_key_indexes.length}: #{idx}"
            end
        end

        return [valid_key_indexes, hashes]
    end

end