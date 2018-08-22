# frozen_string_literal: true

module LinkedList
  class List
    include Conversions

    attr_accessor :length, :head, :tail
    alias_method :size, :length

    def initialize
      @head   = nil
      @tail   = nil
      @length = 0
    end

    # Returns the first element of the list or nil.
    #
    def first
      @head && @head.data
    end

    # Returns the last element of the list or nil.
    #
    def last
      @tail && @tail.data
    end

    # Pushes new nodes to the end of the list.
    #
    # == Parameters:
    # node:: Any object, including +Node+ objects.
    #
    # == Returns:
    # +self+ of +List+ object.
    #
    def push(node)
      node = Node(node, self)
      @head ||= node

      if @tail
        @tail.next = node
        node.prev = @tail
      end

      @tail = node

      @length += 1
      self
    end
    alias_method :<<, :push

    # Pushes new nodes on top of the list.
    #
    # == Parameters:
    # node:: Any object, including +Node+ objects.
    #
    # == Returns:
    # +self+ of +List+ object.
    #
    def unshift(node)
      node = Node(node, self)
      @tail ||= node

      node.next = @head
      @head.prev = node if @head
      @head = node

      @length += 1
      self
    end

    # Inserts after first matched node.data from the the list by passed block or value.
    #
    # == Returns:
    # Inserted node
    #
    def insert_after(to_add, val = nil, &block)
      found_node = each_node.find(&__to_matcher(val, &block))
      return if found_node.blank?
      found_node.insert_after(to_add)
    end

    # Inserts before first matched node.data from the the list by passed block or value.
    #
    # == Returns:
    # Inserted node
    #
    def insert_before(to_add, val = nil, &block)
      found_node = each_node.find(&__to_matcher(val, &block))
      return if found_node.blank?
      found_node.insert_before(to_add)
    end

    # Removes first matched node.data from the the list by passed block or value.
    #
    # == Returns:
    # Deleted node
    #
    def delete(val = nil, &block)
      each_node.find(&__to_matcher(val, &block)).tap do |node_to_delete|
        return if node_to_delete.blank?
        node_to_delete.unlink
      end.data
    end

    # Removes all matched data.data from the the list by passed block or value.
    #
    # == Returns:
    # Array of deleted nodes
    #
    def delete_all(val = nil, &block)
      each_node.select(&__to_matcher(val, &block)).each do |node_to_delete|
        next if node_to_delete.blank?
        node_to_delete.unlink
      end.map(&:data)
    end

    # Removes data from the end of the list.
    #
    # == Returns:
    # Data stored in the node or nil.
    #
    def pop
      return nil unless @head

      tail = __pop
      @head = nil unless @tail

      @length -= 1
      tail.data
    end

    # Removes data from the beginning of the list.
    #
    # == Returns:
    # Data stored in the node or nil.
    #
    def shift
      return nil unless @head

      head = __shift
      @tail = nil unless @head

      @length -= 1
      head.data
    end

    # Reverse list of nodes and returns new instance of the list.
    #
    # == Returns:
    # New +List+ in reverse order.
    #
    def reverse
      List(to_a).reverse!
    end

    # Reverses list of nodes in place.
    #
    # == Returns:
    # +self+ in reverse order.
    #
    def reverse!
      return self unless @head

      __each do |curr_node|
        curr_node.prev, curr_node.next = curr_node.next, curr_node.prev
      end
      @head, @tail = @tail, @head

      self
    end

    # Iterates over nodes from top to bottom passing node data to the block if
    # given. If no block given, returns +Enumerator+.
    #
    # == Returns:
    # +Enumerator+ or yields data to the block stored in every node on the
    # list.
    #
    def each
      return to_enum(__callee__) unless block_given?
      __each { |node| yield(node.data) }
    end

    def each_node
      return to_enum(__callee__) unless block_given?
      __each { |node| yield(node) }
    end

    # Converts list to array.
    #
    def to_a
      each.to_a
    end
    alias_method :to_ary, :to_a

    def inspect
      sprintf('#<%s:%#x %s>', self.class, self.__id__, to_a.inspect)
    end

    # Conversion function, see +Conversions.List+.
    #
    # == Returns:
    # +self+
    #
    def to_list
      self
    end

    private

    def __to_matcher(val = nil, &block)
      raise ArgumentError, 'either value or block should be passed' if val && block_given?
      block = ->(e) { e == val } unless block_given?
      -> (node) { block.call(node.data) }
    end

    def __shift
      head = @head
      @head = @head.next
      head.next = nil
      head
    end

    def __pop
      tail = @tail
      @tail = @tail.prev
      @tail.next = nil if @tail
      tail
    end

    def __each
      curr_node = @head
      while(curr_node)
        yield curr_node
        curr_node = curr_node.next
      end
    end
  end
end
