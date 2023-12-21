require "digest"

class Solution

    def initialize(data = "")
        @door_id = data
    end

    def solution1
        password = ""
        number = 0

        md5 = Digest::MD5.new
        until password.length == 8
            md5.update "#{@door_id}#{number}"
            hash = md5.hexdigest
            if hash.start_with?("00000")
                password += hash[5]
                puts "#{password.length} --> #{number}"
            end
            md5.reset
            number += 1
        end

        puts "========================"
        puts "Solution #1: #{password}"
        puts "========================"
    end

    def solution2
        password = "_" * 8
        number = 0

        md5 = Digest::MD5.new
        until !password.include?("_")
            md5.update "#{@door_id}#{number}"
            hash = md5.hexdigest
            if hash.start_with?("00000")
                position = Integer(hash[5], exception: false)
                if position && password[position] == "_"
                    password[position] = hash[6]
                    puts "#{password} --> #{number}"
                end
            end
            md5.reset
            number += 1
        end

        puts "========================"
        puts "Solution #2: #{password}"
        puts "========================"
    end

end