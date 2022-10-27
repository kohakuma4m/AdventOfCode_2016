class Grid

    # Constructor
    def initialize(width, height, value = 0)
        @width = width
        @height = height
        @data = Array.new(height) { Array.new(width) { value } }
    end

    # Getters & setters
    attr_reader(:width, :height, :data)

    # Methods
    def print(horizontal_separator: "-", vertical_separator: "|")
        border = horizontal_separator * (@width + 2)

        puts border
        @data.each do |row|
            puts "#{vertical_separator}#{row.join("")}#{vertical_separator}"
        end
        puts border
    end

end