require "set"
require "colorize"
require_relative "../lib/coordinate"
require_relative "../lib/grid"
require_relative "../lib/animation"

class Solution

    def initialize(data = "")
        @nodes = self.read_nodes(data)
    end

    def solution1
        viable_pairs = find_viable_pairs(@nodes)

        puts "========================"
        viable_pairs.each { |n1, n2| puts "#{n1} <--> #{n2}" }
        puts "========================"
        puts "Solution #1: #{viable_pairs.length}"
        puts "========================"
    end

    def solution2
        data_grid = DataGrid.new(@nodes)
        frames = move_target_data_to_goal(data_grid)

        puts "========================"
        puts "Solution #2: #{frames.length - 1}"
        animation = Animation.new(frames)
        animation.play(frame_per_second: 24)
        puts "========================"
    end

    ###################################

    NODE_REGEX = /
        \/dev\/grid\/node-x(\d+)-y(\d+) # Node coordinates
        \s+(\d+)T # Size
        \s+(\d+)T # Used
        \s+(\d+)T # Available
        \s+(\d+)% # Used percentage
    /x

    def read_nodes(data)
        nodes = []

        # Skipping two header lines
        data.split("\n")[2..].each do |line|
            x, y, size, used, available, used_pct = line.match(NODE_REGEX).captures.map { |n| Integer(n) }
            node = Node.new(x, y, size, used)

            raise ArgumentError.new("Invalid line: #{line}") if node.available != available || node.used_pct != used_pct
            nodes.push(node)
        end

        nodes
    end

    ##
    # O(n**2) algorithm
    ##
    def find_viable_pairs(nodes)
        pairs = []

        nodes.each do |n1|
            nodes.each do |n2|
                next if n1.used == 0 || n2 == n1 || n1.used > n2.available
                pairs << [n1, n2]
            end
        end

        pairs
    end

    ##
    # Moving target data to goal can be done like this
    #
    # 1) Find shortest path from target to goal
    # 2) Find shortest path from each empty nodes to target
    # 3) Move closest empty node next to target on shortest path to goal
    # 4) Swap target data with empty node
    # 5) Repeat step 3 and 4 until target data is in goal node
    #
    # We don't need to move any nodes since we can calculate paths from known positions of each node at each step
    # We just have to count number of steps from each path, minus one for initial state
    #
    # Each steps are recorded as a snapshot of the data grid in case we want to animate the process
    ##
    def move_target_data_to_goal(data_grid)
        # Find path to use
        path_target_to_goal = data_grid.find_shortest_path(data_grid.target, data_grid.goal)

        # Finding closest empty node from target on path to goal
        nb_target_steps = 0
        path_empty_to_target = data_grid.empty_nodes
            .map { |e| data_grid.find_shortest_path(e, path_target_to_goal.nodes[nb_target_steps + 1], occupied_node: data_grid.target) } # Excluding current target
            .sort_by { |p| p.nodes.length }.first # Keeping only path from shortest node

        # Initial clean frame
        frames = [data_grid.grid.dup]

        # Moving empty node to first step next to target on path to goal
        empty_node = path_empty_to_target.nodes[0]
        empty_node = _move_empty_node(path_empty_to_target, frames, empty_node)

        current_target = data_grid.target
        loop do
            # Swapping target with empty node
            temp = empty_node
            empty_node = current_target
            current_target = temp
            nb_target_steps += 1

            new_frame = frames[-1].dup
            new_frame.data[empty_node.y][empty_node.x] = SYMBOLS[:empty]
            new_frame.data[current_target.y][current_target.x] = SYMBOLS[:target]
            frames.push(new_frame)

            if nb_target_steps >= path_target_to_goal.nodes.length - 1
                break # Goal contains target data
            end

            # Moving empty node to next step on path from target to goal
            path_empty_to_target = data_grid.find_shortest_path(empty_node, path_target_to_goal.nodes[nb_target_steps + 1], occupied_node: current_target) # Excluding current target
            empty_node = _move_empty_node(path_empty_to_target, frames, empty_node)
        end

        frames.map { |f| f.data }
    end

    def _move_empty_node(path_empty_to_target, frames, empty_node)
        path_empty_to_target.nodes[1..].each do |n|
            new_frame = frames[-1].dup
            new_frame.data[empty_node.y][empty_node.x] = SYMBOLS[:node]
            new_frame.data[n.y][n.x] = SYMBOLS[:empty]
            empty_node = n
            frames.push(new_frame)
        end

        empty_node
    end

    class Node < Coordinate

        attr_reader :size
        attr_accessor :used

        def initialize(x, y, size, used)
            super(x, y)
            @size = size
            @used = used
        end

        def available
            @size - @used
        end

        def used_pct
            100 * @used / @size
        end

        def empty?
            @used == 0
        end

        def to_s
            "Node (x#{self.x}-y#{self.y}): #{self.used} / #{self.size} (#{self.used_pct})"
        end

    end

    SYMBOLS = {
        node: ".",
        empty: "_".cyan,
        full: "#".light_white.on_light_black,
        goal: "G".green,
        target: "*".yellow
    }

    class DataGrid

        attr_reader :grid, :target, :goal, :empty_nodes, :full_nodes

        def initialize(nodes, target: nil, goal: nil)
            @nodes_map = nodes.each_with_object({}) {|n, hash| hash[n.key] = n }

            x_max = nodes.map { |n| n.x }.max
            y_max = nodes.map { |n| n.y }.max
            @grid = Grid.new(x_max + 1, y_max + 1, SYMBOLS[:node])

            @target = Coordinate.new(x_max, 0) if !target
            @goal = Coordinate.new(0, 0) if !goal
            @empty_nodes = Set.new
            @full_nodes = Set.new

            self.init_grid(nodes)
        end

        def init_grid(nodes)
            # Grouping connected nodes which can swap data together
            node_groups = []
            nodes.each do |n|
                # Finding if there is an adjacent node in existing groups big enough for node data
                adjacent_nodes = self.get_adjacent_nodes(n)
                group = node_groups.find { |g| g.find { |n2| adjacent_nodes.include?(n2) && n.used < n2.size } }

                if group
                    group.push(n)
                else
                    node_groups.push([n])
                end
            end

            # Marking empty and full nodes
            node_groups.each do |g|
                group_empty_nodes = g.select { |n| n.empty? }
                @empty_nodes.merge(group_empty_nodes)

                g.each do |n|
                    if n.empty?
                        @grid.data[n.y][n.x] = SYMBOLS[:empty]
                    elsif group_empty_nodes.length == 0
                        # Node is inside a connected group of nodes which are not connected to a free empty node
                        @grid.data[n.y][n.x] = SYMBOLS[:full]
                        @full_nodes.add(n)
                    end
                end
            end

            # Target data and goal node
            @grid.data[@target.y][@target.x] = SYMBOLS[:target]
            @grid.data[@goal.y][@goal.x] = SYMBOLS[:goal]
        end

        # O(1) operation because of nodes map
        def get_node(location)
            return @nodes_map["#{location.x}-#{location.y}"]
        end

        # O(1) operation because of nodes map
        def get_adjacent_nodes(node)
            return [
                @nodes_map["#{node.x - 1}-#{node.y}"],
                @nodes_map["#{node.x + 1}-#{node.y}"],
                @nodes_map["#{node.x}-#{node.y - 1}"],
                @nodes_map["#{node.x}-#{node.y + 1}"]
            ].compact
        end

        ##
        #   Returns shortest path between two nodes in data grid (see day 13)
        ##
        def find_shortest_path(start_node, end_node, occupied_node: nil)
            explored_nodes = Set.new([start_node])
            paths_to_explore = [Path.new([start_node])]

            loop do
                paths = paths_to_explore
                paths_to_explore = []

                paths.each do |p|
                    current_node = self.get_node(p.nodes[-1])
                    self.get_adjacent_nodes(current_node)
                        .select { |n| !@full_nodes.include?(n) } # Excluding full nodes which act as walls
                        .select { |n| n.used <= current_node.size && n.size >= current_node.used } # Excluding nodes which have too much data for current node data (or vice-versa in case we want to follow path in reverse)
                        .select { |n| !occupied_node || occupied_node.key != n.key } # Excluding specific extra node, counted as a wall so path does not goes through it
                        .each { |n|
                            if explored_nodes.add?(n)
                                new_path = Path.new(p.nodes + [n])

                                if n.key == end_node.key
                                    return new_path # First found shortest path
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

        #######
        private
        #######

        class Path
            attr_reader :nodes

            def initialize(nodes)
                @nodes = nodes
            end

            def to_s
                @nodes.join("\n")
            end

        end

    end

end