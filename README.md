# Clojure Data Structures in Ruby

## ⚠️ Experimental Project

This is **not an actual library** intended for production use. This project was created by [Wilker](https://github.com/wilkerlucio) and [João Lanjoni](https://github.com/lanjoni) as an experiment to test AI's ability to implement complex data structures.

## What is this?

We wanted to explore whether AI could successfully implement Clojure's persistent vector data structure in Ruby, including:

- Understanding the theoretical concepts from academic papers
- Translating complex algorithms across programming languages
- Implementing efficient bit manipulation and tree structures
- Writing comprehensive tests and benchmarks

## The Implementation

The project contains a Ruby implementation of Clojure's persistent vector, featuring:

- **32-way branching trie** structure for O(log₃₂ n) operations
- **Tail optimization** for efficient appends
- **Structural sharing** with copy-on-write semantics
- **Immutable operations** that return new vectors

### Key Operations

```ruby
# Create vectors
vector = ClojureDsInRuby::PersistentVector[1, 2, 3]
empty = ClojureDsInRuby::PersistentVector.empty

# Access elements
vector.get(0)  # => 1
vector[1]      # => 2

# Add elements (returns new vector)
new_vector = vector.push(4)
new_vector = vector << 5

# Update elements (returns new vector)
updated = vector.set(0, 42)

# All operations preserve immutability
vector.to_a        # => [1, 2, 3] (unchanged)
new_vector.to_a    # => [1, 2, 3, 4, 5]
updated.to_a       # => [42, 2, 3]
```

## Educational Purpose

This implementation serves as:

- A study of persistent data structures
- An exploration of functional programming concepts in Ruby
- A test case for AI-assisted programming
- A reference for understanding Clojure's vector implementation

## References

The implementation is based on these resources:

- [Understanding Persistent Vector (Part 1)](https://hypirion.com/musings/understanding-persistent-vector-pt-1)
- [Understanding Persistent Vector (Part 2)](https://hypirion.com/musings/understanding-persistent-vector-pt-2)  
- [Understanding Persistent Vector (Part 3)](https://hypirion.com/musings/understanding-persistent-vector-pt-3)
- [Ideal Hash Trees Paper](https://lampwww.epfl.ch/papers/idealhashtrees.pdf)

## Running Tests

```bash
bundle install
rake spec
```

## Disclaimer

This code is experimental and not optimized for production use. It was created for educational and research purposes to evaluate AI capabilities in implementing complex algorithms.