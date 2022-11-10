# One way circular linked list
class CircularLinkedList

    # Constructor
    def initialize(items = nil)
        @head = nil
        @current = nil
        @length = 0

        if items.respond_to?(:each)
            items.each do |i|
                self.add_next(i)
                self.move_next
            end
            @current = @head
        end
    end

    # Getters
    attr_reader :length

    def head
        @head&.item
    end

    def current
        @current&.item
    end

    def next
        @current&.next&.item
    end

    #############
    # Methods

    # Add item after current node
    def add_next(item)
        node = Node.new(item)

        if @length == 0
            # First node
            node.next = node
            @current = node
            @head = @current
        else
            # Next node
            node.next = @current.next
            @current.next = node
        end

        @length += 1
    end

    # Remove item after current node
    def remove_next()
        node = nil

        if @length < 2
            # Last node or empty list
            node = @current
            @head = nil
            @current = nil
        else
            # Next node
            node = @current.next
            @head = node.next if @current.next == @head # Head is now the second item
            @current.next = node.next
        end

        @length -= 1 unless @length == 0

        return node&.item # Returning removed item
    end

    # Remove all items from list
    def clear
        while @length > 0
            self.remove_next
        end
    end

    # Move current item one or more position(s) forward in list
    def move_next(n = 1)
        return if n <= 0

        for i in 1 .. n % @length do
            @current = @current.next
        end
    end

    # Map & Block iterator to loop through circular list once, starting at head or current
    def map(start_from_head: true)
        return [] if @length == 0

        list = []

        start = start_from_head ? @head : @current
        node = start
        loop do
            list << (block_given? ? yield(node&.item) : node&.item) # So we can chain with enumerable methods if needed
            break if node.next == start
            node = node.next
        end

        list
    end

    # Convert list to array
    def to_a
        self.map { |item| item }
    end

    # Convert list to string
    def to_s
        self.to_a.to_s
    end

    #############
    private

    # Internal node subclass
    class Node

        # Getters & Setters
        attr_accessor :item, :next

        # Constructor
        def initialize(item)
            @item = item
            @next = nil
        end

    end

end