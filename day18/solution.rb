require "colorize"
require_relative "../lib/grid"

class Solution

    def initialize(data = "")
        @first_row = data
    end

    def solution1
        tiles = generate_room_tiles(@first_row, nb_rows: 40)
        nb_safe_tiles = tiles.data.map { |row| row.count { |t| t == TILES[:safe] } }.sum

        puts "========================"
        tiles.print
        puts "========================"
        puts "Solution #1: #{nb_safe_tiles}"
        puts "========================"
    end

    def solution2
        nb_safe_tiles = count_safe_tiles(@first_row, nb_rows: 400000)

        puts "========================"
        puts "Solution #2: #{nb_safe_tiles}"
        puts "========================"
    end

    ###################################

    TILES = {
        safe: ".".green,
        trap: "^".red
    }

    SAFE_TILE = TILES[:safe].uncolorize
    TRAP_TILE = TILES[:trap].uncolorize

    TRAP_TILE_REGEX = /(\^\^\.|\.\^\^|\^\.\.|\.\.\^)/

    ##
    #   Tile is safe only if previous row (left, center, right) tiles match the following patterns
    #
    #   Safe tile patterns: (Safe, Trap, Safe) OR (Trap, Trap, Trap) OR (Safe, Safe, Safe) OR (Trap, Safe, Trap)
    #
    #   So tile is safe only if left and right tiles are the same, otherwise, it's a trap since it match the following one of the remainging patterns
    #
    #   Trap tile patterns: (Trap, Trap, Safe) OR (Safe, Trap, Trap) OR (Trap, Safe, Safe) OR (Safe, Safe, Trap)
    ##
    def is_safe_tile?(left, right)
        left == right
    end

    ##
    # Generate all room tiles (colored)
    ##
    def generate_room_tiles(first_row, nb_rows: 0)
        tiles = Grid.new(first_row.length, nb_rows, TILES[:safe])

        # First row
        for x in 0 .. tiles.width - 1 do
            tiles.data[0][x] = TILES.find { |k, v| v.uncolorize == first_row[x] }[1]
        end

        # Other rows
        for y in 1 .. nb_rows - 1 do
            previous_row = tiles.data[y - 1]

            # First, middle, last
            tiles.data[y][0] = is_safe_tile?(TILES[:safe], previous_row[1]) ? TILES[:safe] : TILES[:trap]
            for x in 1 .. first_row.length - 2 do
                tiles.data[y][x] = is_safe_tile?(previous_row[x - 1], previous_row[x + 1]) ? TILES[:safe] : TILES[:trap]
            end
            tiles.data[y][-1] = is_safe_tile?(previous_row[-2], TILES[:safe]) ? TILES[:safe] : TILES[:trap]

            puts y if y % 10000 == 0
        end

        return tiles
    end

    ##
    # Only counts safe tiles without generating all room tiles (using uncolorized values only)
    #
    # Note: Slower than using full algorithm above somehow (maybe because of grid data pre-allocation ???)
    ##
    def count_safe_tiles(first_row, nb_rows: 0)
        nb_safe_tiles = first_row.count(SAFE_TILE)
        previous_row = first_row

        for y in 1 .. nb_rows - 1 do
            current_row = " " * first_row.length # MUST be a copy since strings are objects in ruby...

            # First, middle, last
            current_row[0] = is_safe_tile?(SAFE_TILE, previous_row[1]) ? SAFE_TILE : TRAP_TILE
            for x in 1 .. first_row.length - 2 do
                current_row[x] = is_safe_tile?(previous_row[x - 1], previous_row[x + 1]) ? SAFE_TILE : TRAP_TILE
            end
            current_row[-1] = is_safe_tile?(previous_row[-2], SAFE_TILE) ? SAFE_TILE : TRAP_TILE

            nb_safe_tiles += current_row.count(SAFE_TILE)
            previous_row = current_row

            puts nb_safe_tiles if y % 10000 == 0
        end

        return nb_safe_tiles
    end

end