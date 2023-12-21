class Grid

    # Getters & setters
    attr_reader :width, :height, :data

    # Constructor
    def initialize(width, height, value = 0)
        @width = width
        @height = height
        @data = Array.new(height) { Array.new(width) { value } }
    end

    # Deep copy method for "dup"
    def initialize_copy(original)
        @width = original.width
        @height = original.height
        @data = original.data.map { |row| row.map { |col| col } }
    end

    # Comparison function
    def hash
        @data.hash
    end
    def eql?(other) # Called only when hash is different
        if self.width != other.width || self.height != other.height
            return false
        end

        self.height.times { |y|
            self.width.times { |x|
                if self.data[y][x] != other.data[y][x]
                    return false
                end
            }
        }

        return true
    end

    # Methods
    def print(print_map: lambda { |x| x }, horizontal_separator: "-", vertical_separator: "|")
        border = horizontal_separator * (@width + 2)

        puts border
        @data.each do |row|
            puts "#{vertical_separator.ljust(horizontal_separator.length)}#{row.map(&print_map).join("")}#{vertical_separator.rjust(horizontal_separator.length)}"
        end
        puts border
    end

end