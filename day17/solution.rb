require "set"
require "digest"
require "colorize"
require_relative "../lib/coordinate"
require_relative "../lib/grid"
require_relative "../lib/animation"

class Solution

    def initialize(data = "")
        @passcode = data
        @maze = Maze.new("maze.txt")
    end

    def solution1
        path = find_path_to_vault(@maze, @passcode)

        # Animating result
        animation = build_path_animation(@maze, path, show_doors: false)

        puts "========================"
        puts "Solution #1: #{path}"
        animation.play(frame_per_second: 3)
        puts "========================"
    end

    def solution2
        path = find_path_to_vault(@maze, @passcode, find_longest_path: true)

        puts "========================"
        puts "Solution #2: #{path.to_s.length}"
        puts "========================"
    end

    ###################################

    SYMBOLS = {
        wall: "#".light_white.on_light_black,
        door_h: "-",
        door_v: "|",
        open_door_h: "-".green,
        open_door_v: "|".green,
        locked_door_h: "-".red,
        locked_door_v: "|".red,
        room: " ",
        start: "S".cyan,
        vault: "V".magenta,
        path: "*".yellow
    }

    DIRECTIONS = {
        up: "U",
        down: "D",
        left: "L",
        right: "R"
    }

    DIRECTION_HASH_INDEX_MAP = {
        DIRECTIONS[:up] => 0,
        DIRECTIONS[:down] => 1,
        DIRECTIONS[:left] => 2,
        DIRECTIONS[:right] => 3
    }

    def get_hash(passcode, path)
        Digest::MD5.hexdigest("#{passcode}#{path}").downcase
    end

    def self.get_direction_from_locations(l1, l2)
        if l2.x == l1.x
            l2.y > l1.y ? DIRECTIONS[:down] : DIRECTIONS[:up]
        else
            l2.x > l1.x ? DIRECTIONS[:right] : DIRECTIONS[:left]
        end
    end

    ##
    # Exploring paths of increasing number of steps until reaching target location
    # First path found will always be one of the shortest ^_^
    #
    # Note: Since path is always growing, we can't exclude paths returning to previous rooms, as the opened doors could be different
    #
    # If find_longest_path is true, we don't stop at first path, but explore all paths and return longest
    ##
    def find_path_to_vault(maze, passcode, find_longest_path: false)
        paths_to_vault = []
        paths_to_explore = [Path.new([maze.start])]

        loop do
            paths = paths_to_explore
            paths_to_explore = []

            puts "[#{paths[0].to_s.length}] --> #{paths.length}" if find_longest_path && paths[0].to_s.length % 10 == 0

            paths.each do |path|
                current_room = path.locations[-1]
                current_hash = get_hash(passcode, path.to_s)
                opened_doors = maze.get_opened_room_doors(current_room, current_hash)
                locked_doors = maze.get_room_doors(current_room).select { |d| !opened_doors.include?(d) }
                path.opened_doors += [opened_doors]
                path.locked_doors += [locked_doors]

                maze.get_adjacent_rooms(current_room)
                    .each { |room|
                        direction = Solution.get_direction_from_locations(current_room, room)
                        opened_room_door = opened_doors.find { |door| Solution.get_direction_from_locations(current_room, door) == direction }
                        if !opened_room_door
                            next # Skipping locked door
                        end

                        new_path = Path.new(path.locations + [room], opened_doors: path.opened_doors.dup, locked_doors: path.locked_doors.dup)

                        if room == maze.vault
                            # Found a path to vault
                            if find_longest_path
                                paths_to_vault.push(new_path)
                                next # No more path to explore from vault
                            else
                                return new_path # First shortest path found
                            end
                        end

                        paths_to_explore.push(new_path) # New unexplored path
                    }
            end

            if paths_to_explore.length == 0
                if find_longest_path
                    return paths_to_vault.sort_by { |path| -path.to_s.length }.first # First longest path to vault found
                else
                    return nil # No path to vault was found !
                end
            end
        end
    end

    def build_path_animation(maze, path, show_doors: true)
        frames = []
        path.locations.each.with_index { |room, idx|
            data = maze.dup.data # Clean inital grid copy

            # Start/End rooms
            data[maze.start.y][maze.start.x] = SYMBOLS[:start].bold if room == maze.start
            data[maze.vault.y][maze.vault.x] = SYMBOLS[:vault].bold if room == maze.vault

            # Current room
            data[room.y][room.x] = SYMBOLS[:path] if room != maze.start && room != maze.vault

            # Opened/locked doors
            if show_doors
                path.opened_doors[idx]&.each { |door| data[door.y][door.x] = door.x == room.x ? SYMBOLS[:open_door_v] : SYMBOLS[:open_door_h] }
                path.locked_doors[idx]&.each { |door| data[door.y][door.x] = door.x == room.x ? SYMBOLS[:locked_door_v] : SYMBOLS[:locked_door_h] }
            end

            frames.push(data)
        }

        Animation.new(frames)
    end

    class Location < Coordinate

        attr_reader :symbol

        def initialize(symbol, *args)
            @symbol = symbol
            super(*args)
        end

        def to_s
            "Coordinate (#{@x}-#{y}) --> #{SYMBOLS.key(@symbol)}"
        end

    end

    class Path

        attr_reader :locations
        attr_accessor :opened_doors, :locked_doors

        def initialize(locations, opened_doors: [], locked_doors: [])
            @locations = locations
            _init_steps()

            # Optional: only to show animation later...
            @opened_doors = opened_doors
            @locked_doors = locked_doors
        end

        def to_s
            @steps
        end

        ###################################
        private

        def _init_steps
            @steps = ""
            (@locations.length - 1).times do |i|
                @steps += Solution.get_direction_from_locations(@locations[i], @locations[i + 1])
            end
        end

    end

    class Maze < Grid

        attr_reader :start, :vault, :data, :rooms, :doors

        def initialize(maze_filename)
            data = File.read("maze.txt")
            lines = data.split("\n")

            super(lines[0].length, lines.length)
            _init_maze(lines)
        end

        def get_adjacent_rooms(room)
            @rooms.select { |r|
                (r.y == room.y && (r.x - room.x).abs == 2) || (r.x == room.x && (r.y - room.y).abs == 2)
            }
        end

        def get_room_doors(room)
            @doors.select { |d|
                (d.y == room.y && (d.x - room.x).abs == 1) || (d.x == room.x && (d.y - room.y).abs == 1)
            }
        end

        def get_opened_room_doors(room, hash)
            get_room_doors(room).select { |door|
                direction = Solution.get_direction_from_locations(room, door)
                hash[DIRECTION_HASH_INDEX_MAP[direction]].count("bcdef") > 0
            }
        end

        ###################################
        private

        def _init_maze(lines)
            @doors = []
            @rooms = []

            @height.times { |y|
                @width.times { |x|
                    @data[y][x] = SYMBOLS.values.find { |v| v.uncolorize == lines[y][x] } || SYMBOLS[:room]

                    case @data[y][x]
                        when SYMBOLS[:door_h], SYMBOLS[:door_v]
                            @doors.push(Location.new(@data[y][x], x, y))
                        when SYMBOLS[:room]
                            @rooms.push(Location.new(@data[y][x], x, y))
                        when SYMBOLS[:start]
                            @start = Location.new(@data[y][x], x, y)
                            @rooms.push(@start)
                        when SYMBOLS[:vault]
                            @vault = Location.new(@data[y][x], x, y)
                            @rooms.push(@vault)
                    end
                }
            }
        end

    end

end