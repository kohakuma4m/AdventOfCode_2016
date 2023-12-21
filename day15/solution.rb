class Solution

    def initialize(data = "")
        @discs = read_discs_data(data)
    end

    def solution1
        time = find_first_winning_time(@discs)

        puts "========================"
        puts "Solution #1: #{time}"
        puts "========================"
    end

    def solution2
        time = find_first_winning_time(@discs + [Disc.new(11, 0)])

        puts "========================"
        puts "Solution #2: #{time}"
        puts "========================"
    end

    ###################################

    DISC_DATA_REGEX = /^Disc #\d+ has (\d+) positions; at time=0, it is at position (\d+)\.$/

    def read_discs_data(data)
        return data.split("\n").map { |line|
            nb_positions, start_position = line.match(DISC_DATA_REGEX).captures
            Disc.new(Integer(nb_positions), Integer(start_position))
        }
    end

    Disc = Struct.new(:nb_positions, :start_position) {
        def to_s
            "start: #{start_position.to_s.ljust(3)}, frequency: #{nb_positions.to_s.ljust(3)}"
        end
    }

    def find_first_winning_time(discs, slot_position: 0, disc_time_interval: 1)
        slot_positions = discs.map { |d| slot_position % d.nb_positions }
        disc_delays = discs.map.with_index { |_, idx| (idx + 1) * disc_time_interval }
        puts "Slots  : #{slot_positions}\nDelays : #{disc_delays}\n========================"

        idx = 0
        time = 0
        interval = 1
        loop do
            # Matching next disc
            disc = discs[idx]
            until (disc.start_position + time + disc_delays[idx]) % disc.nb_positions == slot_positions[idx]
                time += interval
            end

            puts "time: #{time.to_s.ljust(10)}; interval: #{interval.to_s.ljust(10)} --> #{disc}"

            if idx == discs.length - 1
                break # Last disc was matched
            end

            idx += 1
            interval *= disc.nb_positions
        end

        return time
    end

end