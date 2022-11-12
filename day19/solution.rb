require_relative "../lib/clock_time"
require_relative "../lib/circular_linked_list"

class Solution

    def initialize(data = "")
        @nb_elfs = Integer(data)
    end

    def solution1
        circle = generate_circle(@nb_elfs)
        play_game_v1(circle)

        puts "========================"
        puts "Solution #1: #{circle.current}"
        puts "========================"
    end

    def solution2
        circle = generate_circle(@nb_elfs)
        play_game_v2(circle)

        puts "========================"
        puts "Solution #2: #{circle.current}"
        puts "========================"
    end

    ###################################

    ##
    # Creating circular linked list in O(n) operations
    #
    # Note: since last remaining elf will have all presents, we only have to track elf initial positions (id)
    ##
    def generate_circle(size)
        t1 = ClockTime.now
        print "Creating circular linked list..."
        circle = CircularLinkedList.new([*1..size])
        puts " done in #{(ClockTime.now - t1).round(2)} seconds"

        return circle
    end

    ##
    #   Game version 1
    #
    #   Complexity: O(n) because of circular linked list with O(1) remove operation
    ##
    def play_game_v1(circle)
        puts "Playing game (version 1)..."

        loop do
            puts circle.length if circle.length % 1000000 == 0

            # Taking all gifts from next elf and removing it from list
            circle.remove_next

            # Last remaining elf is the winner
            break if circle.length == 1

            # Moving to next elf
            circle.move_next
        end
    end

    ##
    #   Game version 2
    #
    #   Complexity: O(n) because of circular linked list with O(1) remove operation,
    #               but only if we delay removal operation for later when we reach elf to remove in list
    #
    #         Note: If we removed elf from accross circle after each step, an O(n/2) operation,
    #               the complexity would be O((n+1)!/2**n) instead
    ##
    def play_game_v2(circle)
        puts "Playing game (version 2)..."

        j = 0
        elf_to_remove_at_j = []
        loop do
            puts circle.length if circle.length % 1000000 == 0

            while j == elf_to_remove_at_j[0]
                # Removing next elfs
                circle.remove_next
                elf_to_remove_at_j.shift
            end

            # Last remaining elf is the winner
            break if circle.length == 1

            # Taking all gifts from next elf across circle
            elf_position_to_remove = (circle.length - elf_to_remove_at_j.length) / 2 # Position of elf to remove relative to current elf
            if elf_position_to_remove == 1
                # Removing next elf directly
                circle.remove_next
            else
                # Removing elf later when we reach elf just before him
                elf_to_remove_at_j.push(j + elf_position_to_remove - 1)
            end

            # Moving to next elf
            circle.move_next
            j += 1
        end
    end

end