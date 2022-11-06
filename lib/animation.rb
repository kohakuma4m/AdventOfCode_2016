require_relative "./Grid"

class Animation

    # Constructor
    def initialize(frames = [], width: nil, height: nil)
        @frames = frames
        @width = width || frames[0]&.[0]&.length || 0
        @height = height || frames[0]&.length || 0
    end

    def play(speed: 60)
        refresh_delay = 1.0 / frame_speed # frames / second

        i = 1
        until i == @frames.length
            # Clearing previous frame
            print "\r" + ("\e[A\e[K" * (@height + 2)) if i > 0

            # Showing frame of data
            frame = Grid.new(@width, @height, @frames[i - 1])
            frame.print

            if i == @frames.length
                break # Leaving last frame visible
            end

            # Delay before next frame
            sleep(refresh_delay)

            i += 1
        end
    end

end