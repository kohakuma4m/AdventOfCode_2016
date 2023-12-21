require "set"
require "colorize"
require_relative "../lib/coordinate"
require_relative "../lib/grid"

class Solution

    def initialize(data = "")
        @input = Integer(data)
        @target = Location.new(31, 39)
        @target_length = 51
    end

    def solution1
        maze = Maze.new(@input)
        path, locations = maze.find_path_to(@target)

        puts "========================"
        maze.reveal_all
        maze.show(paths: [path], locations: locations)
        puts "========================"
        puts "Solution #1: #{path ? path.steps.length - 1 : "???"}"
        puts "========================"
    end

    def solution2
        maze = Maze.new(@input)
        paths, locations = maze.find_paths_of_length(@target_length)

        puts "========================"
        maze.show(paths: paths, locations: locations)
        puts "========================"
        puts "Solution #2: #{locations.size}"
        puts "========================"
    end

    ###################################

    SYMBOLS = {
        wall: "#".light_white.on_light_black,
        open: ".".light_black,
        visited: ".".cyan,
        path: "*".green,
        unknown: " ".black
    }

    class Location < Coordinate

        def initialize(*args)
            super(*args)
            @value = @x*@x + 3*@x + 2*@x*@y + @y + @y*@y
        end

        def is_open?(n)
            (@value + n).to_s(2).count("1") % 2 == 0
        end

    end

    class Path
        attr_reader :steps

        def initialize(steps)
            @steps = steps
        end

        def to_s
            @steps.join("\n")
        end

    end

    class Maze
        attr_reader :n, :start, :locations

        def initialize(n, start = Location.new(1, 1))
            @n = n
            @start = start
            @locations_map = { start.key => start }
        end

        def show(paths: [], locations: Set.new(), radius: 1)
            max_x = @locations_map.max_by{ |k,v| v.x }[1].x + radius
            max_y = @locations_map.max_by{ |k,v| v.y }[1].y + radius

            grid = Grid.new(max_x, max_y, SYMBOLS[:unknown])

            max_y.times { |y|
                max_x.times { |x|
                    l = @locations_map["#{x}-#{y}"]
                    if l
                        grid.data[y][x] = l.is_open?(@n) ? (locations.include?(l) ? SYMBOLS[:visited] : SYMBOLS[:open]) : SYMBOLS[:wall]
                    end
                }
            }

            paths.each { |p|
                p.steps.each { |l|
                    grid.data[l.y][l.x] = SYMBOLS[:path]
                }
            }

            grid.print
        end

        def reveal_next_locations(l)
            adjacent_keys = ["#{l.x + 1}-#{l.y}", "#{l.x}-#{l.y + 1}"]
            adjacent_keys.push("#{l.x - 1}-#{l.y}") if l.x > 0
            adjacent_keys.push("#{l.x}-#{l.y - 1}") if l.y > 0

            adjacent_locations = []
            adjacent_keys.each do |key|
                if !@locations_map[key]
                    # Adding new location
                    @locations_map[key] = Location.new(key)
                end
                adjacent_locations.push(@locations_map[key])
            end

            adjacent_locations.select { |a| a.is_open?(@n) }
        end

        def reveal_all(radius: 4)
            max_x = @locations_map.max_by{ |k,v| v.x }[1].x + radius
            max_y = @locations_map.max_by{ |k,v| v.y }[1].y + radius

            max_y.times { |y|
                max_x.times { |x|
                    key = "#{x}-#{y}"
                    if !@locations_map[key]
                        @locations_map[key] = Location.new(key)
                    end
                }
            }
        end

        ##
        # Exploring paths of increasing number of steps until reaching target location
        # First path found will always be one of the shortest ^_^
        #
        # Returns first found path and all visited locations along the way
        ##
        def find_path_to(target, show_maze: false)
            explored_locations = Set.new([@start])
            paths_to_explore = [Path.new([@start])]

            loop do
                paths = paths_to_explore
                paths_to_explore = []

                if show_maze
                    self.show(radius: 4)
                end

                paths.each do |p|
                    current_location = p.steps[-1]
                    reveal_next_locations(current_location)
                        .each { |l|
                            if explored_locations.add?(l)
                                new_path = Path.new(p.steps + [l])

                                if l.key == target.key
                                    return [
                                        new_path, # First found shortest path
                                        explored_locations # All visited locations
                                    ]
                                end

                                paths_to_explore.push(new_path) # New unexplored path
                            end
                        }
                end

                if paths_to_explore.length == 0
                    return nil # No path was found !
                end
            end
        end

        ##
        # Exploring all paths of increasing number of steps until reaching target length
        #
        # Returns all paths of target length and all visited locations along the way
        ##
        def find_paths_of_length(target_length, show_maze: false)
            explored_locations = Set.new([@start])
            paths_to_explore = [Path.new([@start])]

            loop do
                paths = paths_to_explore
                paths_to_explore = []

                if show_maze
                    self.show(radius: 4)
                end

                paths.each do |p|
                    current_location = p.steps[-1]
                    reveal_next_locations(current_location)
                        .each { |l|
                            if explored_locations.add?(l)
                                new_path = Path.new(p.steps + [l])
                                paths_to_explore.push(new_path) # New unexplored path
                            end
                        }
                end

                if paths_to_explore.length == 0
                    return [] # No path of target length was found !
                end

                if paths_to_explore[0].steps.length == target_length
                    return [
                        paths_to_explore, # All paths of target length
                        explored_locations  # All visited locations
                    ]
                end
            end
        end

    end

end