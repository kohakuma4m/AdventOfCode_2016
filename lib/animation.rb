require_relative "./Grid"

class Animation

    # Constructor
    def initialize(frames = [], width: nil, height: nil)
        @frames = frames
        @width = width || frames[0]&.first.length || 0
        @height = height || frames[0]&.length || 0
    end

    # Methods
    def play(print_map: lambda { |x| x }, frame_per_second: 60)
        refresh_delay = 1.0 / frame_per_second

        i = 0
        until i == @frames.length
            # Clearing previous frame
            print "\r" + ("\e[A\e[K" * (@height + 2)) if i > 0

            # Showing frame of data
            frame = Grid.new(@width, @height)
            @height.times { |y|
                @width.times { |x|
                    frame.data[y][x] = print_map.call(@frames[i][y][x])
                }
            }
            frame.print(horizontal_separator: " ", vertical_separator: " ")

            if i == @frames.length
                break # Leaving last frame visible
            end

            # Delay before next frame
            sleep(refresh_delay)

            i += 1
        end
    end

end