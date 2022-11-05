require "set"

class Solution

    def initialize(data = "")
        @rooms = data.split("\n")
            .map { |line| Room.new(*line.match(ROOM_REGEX).captures) }
            .select(&method(:real_room?))
    end

    def solution1
        # Summing real rooms sector ids
        sum = @rooms.reduce(0) { |total, room| total + Integer(room.sector_id) }

        puts "========================"
        puts "Valid rooms: #{@rooms.length}"
        puts "========================"
        puts "Solution #1: #{sum}"
        puts "========================"
    end

    def solution2
        # Decrypting rooms name (in lowercase)
        @rooms.each do |room|
            room.name = room.name.split("")
                .map { |c| c == "-" ? " " : rotate_lowercase_letter(c, Integer(room.sector_id)) }
                .join("")
        end

        # Finding north pole room
        northPoleRoom = @rooms.find { |room| room.name.include?("north") && room.name.include?("pole") }

        puts "========================"
        puts "Room: #{northPoleRoom.name}"
        puts "========================"
        puts "Solution #2: #{northPoleRoom.sector_id}"
        puts "========================"
    end

    ###################################

    ROOM_REGEX = /^([a-z-].+)-(\d+)\[([a-z]+)\]$/
    Room = Struct.new(:name, :sector_id, :checksum)

    def real_room?(room)
        most_frequent_letters = Set.new(room.name.gsub("-", "").split(""))
            .map { |c| [c, (room.name.count c)] }
            .sort_by { |c, count| [-count, c] } # Most frequent first, then in alphabetical order
            .first(5)
            .map { |c, count| c }
            .join("")

        return most_frequent_letters.eql?(room.checksum)
    end

    def rotate_lowercase_letter(letter, number)
        letter_value = letter.bytes[0] - 96
        rotated_letter_value = (letter_value + number % 26 - 1) % 26 + 1

        return (rotated_letter_value + 96).chr
    end

end