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

    def to_s
        "Coordinate (#{@x}-#{y})"
    end

    def hash
        @key.hash
    end
    def eql?(other)
        return self.key == other.key
    end
end