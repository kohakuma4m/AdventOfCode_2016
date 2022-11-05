require "set"
require_relative "../lib/grid"

class Solution

    def initialize(data = "")
        @data = data
    end

    def solution1
        items = read_items(@data)
        facility = Facility.new(items)
        facility.show

        solution = find_solution(facility)

        puts "========================"
        solution.moves.each { |m| puts m }
        solution.facility.show
        puts "========================"
        puts "Solution #1: #{solution.moves.length}"
        puts "========================"
    end

    def solution2
        lines = @data.split("\n")
        lines[0] += "An elerium generator. An elerium-compatible microchip. A dilithium generator. A dilithium-compatible microchip."
        items = read_items(lines.join("\n"))

        facility = Facility.new(items)
        facility.show

        solution = find_solution(facility)

        puts "========================"
        solution.moves.each { |m| puts m }
        solution.facility.show
        puts "========================"
        puts "Solution #2: #{solution.moves.length}"
        puts "========================"
    end

    ###################################

    SYMBOLS = {
        empty: ".",
        floor: "F",
        elevator: "E",
        generator: "G",
        microchip: "M"
    }

    DIRECTIONS = {
        up: "UP",
        down: "DOWN"
    }

    Item = Struct.new(:key, :floor, :position) {
        def element
            key[0]
        end
        def type
            key[1]
        end
        def to_s
            "#{key} (#{floor})"
        end
    }

    Move = Struct.new(:items, :floor) {
        def to_s
            "[#{items.join(", ")}] --> #{floor}"
        end
    }

    Solution = Struct.new(:facility, :moves)

    GENERATOR_REGEX = / (\w+) generator/
    MICROCHIP_REGEX = / (\w+)-compatible microchip/

    def read_items(data)
        items = []

        data.split("\n").each.with_index do |line, index|
            floor = index + 1

            line.scan(GENERATOR_REGEX).each { |(element)|
                items.push(Item.new("#{element[0].upcase}#{SYMBOLS[:generator]}", floor, items.length + 1))
            }

            line.scan(MICROCHIP_REGEX).each { |(element)|
                items.push(Item.new("#{element[0].upcase}#{SYMBOLS[:microchip]}", floor, items.length + 1))
            }
        end

        return items
    end

    def is_safe_floor?(floor_items)
        non_matching_items = floor_items.select { |i| !floor_items.find { |i2| i2.key != i.key && i2.element == i.element } }

        if non_matching_items.length < 2
            return true # Floor has only matched items or single non matched item
        end

        # Floor has only non matched microchips
        return !non_matching_items.find { |i| i.type == SYMBOLS[:generator] }
    end

    def is_safe_move?(floor_items, target_floor_items, items)
        current_floor_items = floor_items.filter { |i| !items.find { |i2| i2.key == i.key } }
        target_floor_items = target_floor_items + items

        return is_safe_floor?(current_floor_items) && is_safe_floor?(target_floor_items)
    end

    def find_best_safe_moves(facility, target_floor: 4)
        # Floor items to move (exluding matching items already on target floor)
        floor_items = facility.get_floor_items(facility.current_floor, exclude_matching_items: facility.current_floor == target_floor)
        # Target floors (excluding empty floors below current floor)
        reachable_floors = facility.get_reachable_floors(exclude_lower_empty_floors: false) # Should always be false to avoid missing solution...
        # Target direction: Up or down toward target floor
        target_direction = facility.current_floor <= target_floor ? DIRECTIONS[:up] : DIRECTIONS[:down]

        # Optimisation 2) Excluding items from duplicate item pairs, since moving items from any pair is symmetrical
        items_to_move = floor_items
        matching_items = floor_items.select { |i| floor_items.find { |i2| i2.key != i.key && i2.element == i.element } }
        if matching_items.length > 2
            # Keeping only first matching pair, as any matching pair of items is the same
            first_matching_items = [matching_items[0], matching_items.find { |i2| i2.key != matching_items[0].key && i2.element == matching_items[0].element }]
            duplicate_items = matching_items.select { |i| !first_matching_items.find { |i2| i2.key == i.key } }
            items_to_move = floor_items.select { |i| !duplicate_items.find { |i2| i2.key == i.key } }
        end

        moves = []
        reachable_floors.each do |floor|
            direction = facility.current_floor < floor ? DIRECTIONS[:up] : DIRECTIONS[:down]
            target_floor_items = facility.get_floor_items(floor, exclude_matching_items: true)

            # Optimisation 1a) Moving as many items as possible toward target floor, or as few item as possible away from target floor
            combinations = items_to_move.combination(direction == target_direction ? 2 : 1).select { |items| is_safe_move?(floor_items, target_floor_items, items) }
            combinations.each { |items| moves.push(Move.new(items, floor)) }

            if combinations.length == 0
                # Optimisation 1b) Moving less items toward target floor, or more item away from target floor only if there is no other possible move
                items_to_move.combination(direction == target_direction ? 1: 2).select { |items| is_safe_move?(floor_items, target_floor_items, items) }
                    .each { |items| moves.push(Move.new(items, floor)) }
            end
        end

        return moves
    end

    ##
    # Exploring all new unique facility states of increasing number of moves until a solution is found`
    #
    #   Runtime: About 30s (part1) and more than 70 minutes (part 2)
    #
    # Optimisation #1: Excluding less optimal moves that needlessly increase move counts
    #
    #   Runtime: Less than 8s (part1), and more than 16 minutes (part 2)
    #
    # Optimisation #2: Excluding moves from duplicate pairs of matching items, since moving items from any pair is symmetrical
    #
    #   Runtime: Less than 2s (part1), and less than 1 minute (part 2)
    ##
    def find_solution(facility, target_floor: 4)
        visited_states = Set.new([facility])
        solutions_to_process = [Solution.new(facility, [])]

        loop do
            solutions = solutions_to_process
            solutions_to_process = []

            puts "#{solutions.map { |s| s.moves.length }.uniq}: #{solutions.length}"

            solutions.each do |s|
                # Finding only safe moves which goes fastest toward target floor
                find_best_safe_moves(s.facility, target_floor: target_floor)
                    .each { |m|
                        new_facility = s.facility.dup
                        new_facility.move_items_with_elevator(m.items, m.floor)

                        if visited_states.add?(new_facility)
                            # New unvisited state
                            solutions_to_process.push(Solution.new(new_facility, s.moves.dup.push(m)))

                            if new_facility.get_floor_items(target_floor).length === facility.items.length
                                return solutions_to_process[-1] # Solution found
                            end
                        end
                    }
            end

            if solutions_to_process.length == 0
                return nil # No solution was found !
            end
        end
    end

    class InvalidOperation < ArgumentError
    end

    class Facility < Grid

        # Constructor
        def initialize(items, nb_floors: 4, elevator_floor: 1)
            raise ArgumentError.new("Number of floors must be at least 2 !") if nb_floors < 2

            @items = items
            @elevator = Item.new(SYMBOLS[:elevator], elevator_floor)
            @nb_floors = nb_floors

            super(items.length + 2, @nb_floors, SYMBOLS[:empty].ljust(3))

            nb_floors.times { |n| @data[-(n + 1)][0] = "#{SYMBOLS[:floor]}#{n + 1}".ljust(3) }
            @data[-@elevator.floor][1] = SYMBOLS[:elevator].ljust(3)
            items.each { |item| @data[-item.floor][item.position + 1] = item.key.ljust(3) }
        end

        # Deep copy method for "dup"
        def initialize_copy(original)
            @items = original.items.map{ |i| Item.new(i.key, i.floor, i.position) }
            @elevator = Item.new(SYMBOLS[:elevator], original.current_floor)
            @nb_floors = original.nb_floors
            super(original)
        end

        # Getters & setters
        attr_reader(:nb_floors, :items)

        def current_floor
            return @elevator.floor
        end

        # Methods

        def move_items_with_elevator(items, floor)
            raise InvalidOperation.new("Can only move two items at most !") if items.length > 2
            raise InvalidOperation.new("Can only move one floor at a time !") if (floor - current_floor).abs > 1
            raise InvalidOperation.new("Can only move items on current floor !") if items.find { |item| item.floor != current_floor }

            move_elevator(floor)
            items.each { |item| move_item(item, floor) }
        end

        def get_floor_items(floor, exclude_matching_items: false)
            floor_items = @items.select { |item| item.floor == floor }

            if !exclude_matching_items
                return floor_items
            end

            return floor_items.select { |i| !floor_items.find { |i2| i2.key != i.key && i2.element == i.element } }
        end

        def get_reachable_floors(exclude_lower_empty_floors: false)
            if current_floor == 1
                return [current_floor + 1]
            elsif current_floor == @nb_floors
                return [current_floor - 1]
            else
                floors = [current_floor + 1]
                if !exclude_lower_empty_floors || get_floor_items(current_floor - 1).length == 0
                    floors.push(current_floor - 1)
                end
                return floors
            end
        end

        def show
            print(horizontal_separator: "-" * 3)
        end

        #######
        private
        #######

        def move_elevator(floor)
            @data[-@elevator.floor][1] = SYMBOLS[:empty].ljust(3)
            @elevator.floor = floor
            @data[-@elevator.floor][1] = SYMBOLS[:elevator].ljust(3)
        end

        def move_item(item, floor)
            item = @items.find { |i| i.key == item.key }

            @data[-item.floor][item.position + 1] = SYMBOLS[:empty].ljust(3)
            item.floor = floor
            @data[-item.floor][item.position + 1] = item.key.ljust(3)
        end
    end

end