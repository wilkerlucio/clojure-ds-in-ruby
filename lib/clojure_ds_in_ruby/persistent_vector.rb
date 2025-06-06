# frozen_string_literal: true

module ClojureDsInRuby
  class PersistentVector
    include Enumerable

    BITS = 5
    BRANCH_FACTOR = 1 << BITS # 32
    MASK = BRANCH_FACTOR - 1  # 31

    attr_reader :size, :shift, :root, :tail

    def initialize(size = 0, shift = BITS, root = nil, tail = [])
      @size = size
      @shift = shift
      @root = root
      @tail = tail.frozen? ? tail : tail.dup.freeze
    end

    def self.[](*elements)
      new.concat(elements)
    end

    def self.empty
      new
    end

    def empty?
      @size == 0
    end

    def length
      @size
    end
    alias count length

    def get(index)
      return nil if index < 0 || index >= @size

      if index >= tail_offset
        @tail[index - tail_offset]
      else
        get_from_trie(index)
      end
    end
    alias [] get

    def set(index, value)
      return nil if index < 0 || index >= @size

      if index >= tail_offset
        new_tail = @tail.dup
        new_tail[index - tail_offset] = value
        PersistentVector.new(@size, @shift, @root, new_tail)
      else
        new_root = set_in_trie(@root, @shift, index, value)
        PersistentVector.new(@size, @shift, new_root, @tail)
      end
    end
    alias assoc set

    def push(value)
      if @tail.length < BRANCH_FACTOR
        new_tail = @tail + [value]
        PersistentVector.new(@size + 1, @shift, @root, new_tail)
      else
        new_root, new_shift = push_tail_into_trie
        new_tail = [value]
        PersistentVector.new(@size + 1, new_shift, new_root, new_tail)
      end
    end
    alias conj push
    alias << push

    def pop
      return self if empty?

      if @tail.length > 1
        new_tail = @tail[0...-1]
        PersistentVector.new(@size - 1, @shift, @root, new_tail)
      elsif @root.nil?
        PersistentVector.new(0, BITS, nil, [])
      else
        new_tail, new_root, new_shift = pop_tail_from_trie
        PersistentVector.new(@size - 1, new_shift, new_root, new_tail)
      end
    end

    def concat(other)
      return self if other.empty?

      result = self
      other.each { |item| result = result.push(item) }
      result
    end
    alias + concat

    def each(&block)
      return enum_for(:each) unless block_given?

      (0...@size).each { |i| yield get(i) }
    end

    def to_a
      each.to_a
    end

    def ==(other)
      return false unless other.is_a?(PersistentVector)
      return false unless @size == other.size

      (0...@size).all? { |i| get(i) == other.get(i) }
    end

    def inspect
      "#<PersistentVector #{to_a.inspect}>"
    end
    alias to_s inspect

    private

    def tail_offset
      return 0 if @size < BRANCH_FACTOR

      (((@size - 1) >> BITS) << BITS)
    end

    def get_from_trie(index)
      node = @root
      level = @shift

      while level > BITS
        node = node[(index >> (level - BITS)) & MASK]
        return nil if node.nil?
        level -= BITS
      end

      node[index & MASK]
    end

    def set_in_trie(node, level, index, value)
      if level == BITS
        new_node = node.dup
        new_node[index & MASK] = value
        new_node.freeze
      else
        subindex = (index >> level) & MASK
        new_node = node.dup
        new_node[subindex] = set_in_trie(node[subindex], level - BITS, index, value)
        new_node.freeze
      end
    end

    def push_tail_into_trie
      if @root.nil?
        # First overflow: current tail becomes the root
        [@tail.freeze, BITS]
      else
        # Check if we can fit another leaf at the current level
        leaves_at_current_level = 1 << (@shift - BITS)
        current_leaf_index = tail_offset >> BITS
        
        if current_leaf_index < leaves_at_current_level
          # Can fit in current structure
          if @shift == BITS
            # Root is currently a single leaf, make it a branch
            [[@root, @tail.freeze].freeze, @shift + BITS]
          else
            # Root is already a branch, add to it
            [add_leaf_to_trie(@root, @shift, tail_offset, @tail.freeze), @shift]
          end
        else
          # Need new level  
          [[@root, @tail.freeze].freeze, @shift + BITS]
        end
      end
    end

    def add_leaf_to_trie(node, level, index, leaf)
      if level == BITS
        # This node IS the leaf level (contains actual values)
        # We can't add to it, this shouldn't happen
        raise "Trying to add leaf to leaf node"
      else
        # This is a branch node containing other nodes
        subindex = (index >> (level - BITS)) & MASK
        new_node = extend_array(node, subindex + 1)
        new_node[subindex] = leaf
        new_node.freeze
      end
    end

    def extend_array(arr, new_size)
      if arr.length >= new_size
        arr.dup
      else
        result = arr.dup
        result.fill(nil, arr.length, new_size - arr.length)
        result
      end
    end

    def pop_tail_from_trie
      if tail_offset == BRANCH_FACTOR
        # Grab the rightmost leaf as the new tail
        [rightmost_leaf, nil, BITS]
      else
        new_root, new_tail = pop_tail_rec(@root, @shift, tail_offset - 1)
        
        # Check if we can reduce tree height
        new_shift = @shift
        while new_shift > BITS && new_root && new_root.length == 1
          new_root = new_root[0]
          new_shift -= BITS
        end

        [new_tail, new_root, new_shift]
      end
    end

    def pop_tail_rec(node, level, target_index)
      subindex = ((target_index >> level) & MASK)

      if level > BITS
        # Internal node
        new_child, tail = pop_tail_rec(node[subindex], level - BITS, target_index)
        
        if new_child.nil? && subindex == 0
          # This node becomes empty
          [nil, tail]
        else
          # Update this node
          new_node = node[0...subindex].dup
          new_node << new_child if new_child
          [new_node.freeze, tail]
        end
      else
        # Leaf node
        tail = node[subindex]
        new_node = subindex == 0 ? nil : node[0...subindex].freeze
        [new_node, tail]
      end
    end

    def rightmost_leaf
      node = @root
      level = @shift

      while level > BITS
        node = node[-1]
        level -= BITS
      end

      node[-1]
    end
  end
end