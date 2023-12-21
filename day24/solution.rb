require "set"
require "colorize"
require_relative "../lib/coordinate"
require_relative "../lib/grid"

class Solution

    def initialize(data = "")
        @maze = Maze.new(data)
    end

    def solution1
        # Finding shortest path from start, visiting all locations
        path = find_shortest_full_path(@maze)

        # Highlighting path
        @maze.color_path(path)
        @maze.print

        puts "========================"
        puts "Solution #1: #{path.locations.length - 1}"
        puts "========================"
    end

    def solution2
        # Finding shortest path from start, visiting all locations, then returning to start
        path = find_shortest_full_path(@maze, return_to_start: true)

        # Highlighting path
        @maze.color_path(path)
        @maze.print

        puts "========================"
        puts "Solution #2: #{path.locations.length - 1}"
        puts "========================"
    end

    ###################################

    SYMBOLS = {
        "#" => :wall,
        "." => :passage,
        "*" => :path
    }

    SYMBOLS_PRINT_MAP = {
        :wall => "#".light_black,#light_white.on_light_black,
        :passage => ".",
        :path => "*".blue
    }

    class Location < Coordinate
        attr_reader :symbol
        attr_accessor :adjacent_locations

        def initialize(symbol, *args)
            super(*args)
            @symbol = symbol
            @adjacent_locations = []
        end

        def to_s
            "Location (#{@x}-#{y}) --> #{@adjacent_locations.length} adjacent locations"
        end

    end

    class Path
        attr_reader :start, :end, :locations

        def initialize(locations)
            @locations = locations.freeze # Paths are immutable
            @start = locations[0]
            @end = locations[-1]
        end

        def to_s
            "Path #{@start.symbol} --> #{@end.symbol} (#{@locations.length})"
        end

    end

    class Maze < Grid
        attr_reader :start, :targets

        def initialize(data)
            lines = data.split("\n")
            super(lines[0].length, lines.length)
            _init_maze(lines)
        end

        def print
            super(print_map: lambda { |s| SYMBOLS_PRINT_MAP[s] || s.to_s.green })
        end

        def color_path(path)
            path.locations.each { |location|
                @data[location.y][location.x] = :path unless @data[location.y][location.x].is_a? Integer
            }
        end

        ###################################
        private

        def _init_maze(lines)
            @targets = []
            @locations_map = {}

            # Filling grid and non wall locations
            @height.times { |y|
                @width.times { |x|
                    c = lines[y][x]
                    @data[y][x] = SYMBOLS[c] || Integer(c)
                    next if @data[y][x] == :wall

                    location = Location.new(@data[y][x], x, y)
                    @locations_map[location.key] = location
                    next if @data[y][x] == :passage

                    if @data[y][x] == 0
                        @start = location
                    else
                        @targets << location
                    end
                }
            }

            # Binding all adjacent non wall locations together
            @height.times { |y|
                @width.times { |x|
                    @locations_map["#{x}-#{y}"]&.adjacent_locations = [
                        @locations_map["#{x - 1}-#{y}"],
                        @locations_map["#{x + 1}-#{y}"],
                        @locations_map["#{x}-#{y - 1}"],
                        @locations_map["#{x}-#{y + 1}"]
                    ].compact
                }
            }
        end

    end

    ##
    # Find all shortest paths between two maze locations
    ##
    def find_all_shortest_paths(maze, location1, location2)
        explored_locations = Set.new([location1])
        paths_to_explore = [Path.new([location1])]
        shortest_paths = []

        loop do
            current_paths = paths_to_explore
            paths_to_explore = []

            current_paths.each do |path|
                current_location = path.locations[-1]
                current_location.adjacent_locations.each do |location|
                    if explored_locations.add?(location)
                        new_path = Path.new(path.locations + [location])

                        if location == location2
                            shortest_paths << new_path # Found new shortest path
                        end

                        paths_to_explore.push(new_path) # New unexplored path
                    end
                end
            end

            if shortest_paths.length > 0
                return shortest_paths # All shortest paths were found
            end

            if paths_to_explore.length == 0
                return nil # No path found between the two locations
            end
        end
    end

    ##
    # Find shortest full path from maze start location which visits all maze target locations
    ##
    def find_shortest_full_path(maze, return_to_start: false)
        # 1) Find all visiting order, always starting from start
        location_orders = maze.targets.permutation.map { |p|
            if return_to_start
                [maze.start] + p + [maze.start]
            else
                [maze.start] + p
            end
        }

        # 2) Find all shortest paths between all locations
        paths_index = {}
        @maze.targets.each do |target| # Path from start to each target
            paths = find_all_shortest_paths(@maze, @maze.start, target)
            paths_index["#{@maze.start.symbol}-#{target.symbol}"] = paths
            if return_to_start # Path from each target to start
                paths_index["#{target.symbol}-#{@maze.start.symbol}"] = paths.map { |p| Path.new(p.locations.reverse) }
            end
        end
        target_combinations = @maze.targets.combination(2).to_a
        target_combinations.each do |(l1, l2)| # Path from each pair of targets
            paths_index["#{l1.symbol}-#{l2.symbol}"] = find_all_shortest_paths(@maze, l1, l2)
        end
        target_combinations.each do |(l1, l2)| # Adding missing reversed path
            key = "#{l1.symbol}-#{l2.symbol}"
            reverse_key = "#{l2.symbol}-#{l1.symbol}"
            if !paths_index[reverse_key]
                paths_index[reverse_key] = paths_index[key].map { |p| Path.new(p.locations.reverse) }
            end
        end

        # 3) Find all complete paths
        full_paths = []
        location_orders.each do |locations|
            paths_to_explore = []
            paths_index["#{locations[0].symbol}-#{locations[1].symbol}"].each do |p|
                paths_to_explore << [p]
            end

            while paths_to_explore.length > 0
                partial_paths = paths_to_explore
                paths_to_explore = []

                partial_paths.each do |path_segments|
                    paths_index["#{locations[path_segments.length].symbol}-#{locations[path_segments.length + 1].symbol}"].each do |next_path_segment|
                        partial_path = path_segments + [Path.new(next_path_segment.locations[1..])] # Excluding overlapping path segments

                        if path_segments.length == locations.length - 2
                            # That was the last path segment
                            full_paths << Path.new(partial_path.map { |p| p.locations }.flatten)
                        else
                            # Next path fragments
                            paths_to_explore << partial_path
                        end
                    end
                end
            end
        end

        # Sorting all paths by length
        full_paths.sort_by! { |p| p.locations.length }

        return full_paths[0] # Shortest path
    end

end