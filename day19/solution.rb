require_relative "../lib/clock_time"
require_relative "../lib/circular_linked_list"

class Solution

    def initialize(data = "")
        @nb_elfs = Integer(data)
    end

    def solution1
        t1 = ClockTime.now
        print "Creating circular linked list..."
        circle = CircularLinkedList.new Array.new(@nb_elfs).map.with_index { |_, n| Elf.new(n + 1, 1) }
        puts " done in #{(ClockTime.now - t1).round(2)} seconds"

        puts "Playing game..."
        loop do
            # Taking all gifts from next elf and removing it from list
            circle.current.nb_gifts += circle.next.nb_gifts
            circle.remove_next

            # Last remaining elf is the winner
            break if circle.length == 1

            # Moving to next elf
            circle.move_next

            puts circle.length if circle.length % 1000000 == 0
        end

        puts "========================"
        puts "Solution #1: #{circle.current.id}"
        puts "========================"
    end

    def solution2
        puts "========================"
        puts "Solution #2: #{nil}"
        puts "========================"
    end

    ###################################

    Elf = Struct.new(:id, :nb_gifts) {
        def to_s
            "#{self.id}: #{self.nb_gifts}"
        end
    }

end