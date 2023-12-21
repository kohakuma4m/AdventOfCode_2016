class Coordinate

    # Getters & setters
    attr_reader :x, :y, :key

    # Constructor
    def initialize(*args)
        if args.length == 2 && args[0].is_a?(Integer) && args[1].is_a?(Integer)
            @x = args[0]
            @y = args[1]
            @key = "#{@x}-#{@y}"
        elsif args.length == 1 && args[0]
            @key = args[0]
            @x, @y = @key.split("-").map { |n| Integer(n) }
        else
            raise ArgumentError.new("Coordinate construtor: #{args} does not match (x, y) or (key) signature")
        end
    end

    # Deep copy method for "dup"
    def initialize_copy(original)
        @x = original.x
        @y = original.y
        @key = original.key
    end

    # Comparison function
    def hash
        @key.hash
    end
    def eql?(other) # Called only when hash is different
        return self.key == other.key
    end

    def to_s
        "Coordinate (#{@x}-#{y})"
    end

end