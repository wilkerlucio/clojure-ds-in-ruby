# frozen_string_literal: true

require "spec_helper"
require "benchmark"

RSpec.describe ClojureDsInRuby::PersistentVector, :benchmark do
  PersistentVector = ClojureDsInRuby::PersistentVector
  let(:small_size) { 100 }
  let(:medium_size) { 1_000 }
  let(:large_size) { 10_000 }

  describe "performance benchmarks" do
    it "benchmarks push operations" do
      puts "\n=== Push Performance ==="

      array_time = Benchmark.realtime do
        array = []
        small_size.times { |i| array = array + [i] }
      end

      vector_time = Benchmark.realtime do
        vector = PersistentVector.empty
        small_size.times { |i| vector = vector.push(i) }
      end

      puts "Array (#{small_size} elements): #{array_time.round(4)}s"
      puts "PersistentVector (#{small_size} elements): #{vector_time.round(4)}s"

      expect(vector_time).to be < array_time * 10 # Should be much faster
    end

    it "benchmarks random access" do
      puts "\n=== Random Access Performance ==="

      # Build test data
      array = (0...medium_size).to_a
      vector = array.reduce(PersistentVector.empty) { |v, i| v.push(i) }
      indices = Array.new(100) { rand(medium_size) }

      array_time = Benchmark.realtime do
        indices.each { |i| array[i] }
      end

      vector_time = Benchmark.realtime do
        indices.each { |i| vector.get(i) }
      end

      puts "Array random access (#{medium_size} elements): #{array_time.round(6)}s"
      puts "PersistentVector random access (#{medium_size} elements): #{vector_time.round(6)}s"

      expect(vector_time).to be < 0.1 # Should be very fast
    end

    it "benchmarks structural sharing" do
      puts "\n=== Structural Sharing Performance ==="

      base_vector = (0...medium_size).reduce(PersistentVector.empty) { |v, i| v.push(i) }

      sharing_time = Benchmark.realtime do
        10.times do |i|
          base_vector.push(medium_size + i)
        end
      end

      copying_time = Benchmark.realtime do
        base_array = (0...medium_size).to_a
        10.times do |i|
          base_array + [medium_size + i]
        end
      end

      puts "PersistentVector sharing (#{medium_size} base): #{sharing_time.round(6)}s"
      puts "Array copying (#{medium_size} base): #{copying_time.round(6)}s"

      expect(sharing_time).to be < copying_time
    end

    it "benchmarks updates" do
      puts "\n=== Update Performance ==="

      array = (0...small_size).to_a
      vector = array.reduce(PersistentVector.empty) { |v, i| v.push(i) }

      array_time = Benchmark.realtime do
        10.times do |i|
          new_array = array.dup
          new_array[i] = 999
        end
      end

      vector_time = Benchmark.realtime do
        10.times do |i|
          vector.set(i, 999)
        end
      end

      puts "Array updates (#{small_size} elements): #{array_time.round(6)}s"
      puts "PersistentVector updates (#{small_size} elements): #{vector_time.round(6)}s"

      expect(vector_time).to be < array_time * 2
    end

    it "demonstrates memory efficiency" do
      puts "\n=== Memory Efficiency Demo ==="

      # Create base vector
      base = (0...1000).reduce(PersistentVector.empty) { |v, i| v.push(i) }

      # Create many derived vectors
      derived_vectors = []
      20.times do |i|
        derived_vectors << base.push(1000 + i)
      end

      # All derived vectors should share structure with base
      # We can't measure memory directly, but we can verify correctness
      derived_vectors.each_with_index do |vector, i|
        expect(vector.size).to eq(1001)
        expect(vector.get(1000)).to eq(1000 + i)
        expect(vector.get(500)).to eq(500) # Shared with base
      end

      puts "Created 20 derived vectors from base of 1000 elements"
      puts "Each derived vector shares structure with base"
    end

    it "benchmarks hash computation and caching" do
      puts "\n=== Hash Performance ==="

      # Create test vectors
      large_vector = (0...medium_size).reduce(PersistentVector.empty) { |v, i| v.push(i) }
      equal_vector = (0...medium_size).reduce(PersistentVector.empty) { |v, i| v.push(i) }
      different_vector = (1..medium_size).reduce(PersistentVector.empty) { |v, i| v.push(i) }

      # Benchmark first hash computation
      first_hash_time = Benchmark.realtime do
        large_vector.hash
      end

      # Benchmark cached hash access
      cached_hash_time = Benchmark.realtime do
        100.times { large_vector.hash }
      end

      # Benchmark equality with hash optimization
      equality_time = Benchmark.realtime do
        100.times do
          large_vector == equal_vector
          large_vector == different_vector
        end
      end

      puts "First hash computation (#{medium_size} elements): #{first_hash_time.round(6)}s"
      puts "Cached hash access (100 calls): #{cached_hash_time.round(6)}s"
      puts "Equality checks with hash optimization (200 comparisons): #{equality_time.round(6)}s"

      # Hash should be much faster after caching
      expect(cached_hash_time).to be < first_hash_time
      expect(equality_time).to be < 0.1  # Should be very fast
    end

    it "benchmarks hash-based collection integration" do
      puts "\n=== Hash Collection Integration ==="

      vectors = (1..100).map do |i|
        (0...10).reduce(PersistentVector.empty) { |v, j| v.push(i * 10 + j) }
      end

      # Benchmark Ruby Set operations
      set_time = Benchmark.realtime do
        require 'set'
        set = Set.new(vectors)
        vectors.each { |v| set.include?(v) }
      end

      # Benchmark Ruby Hash operations
      hash_time = Benchmark.realtime do
        hash_table = {}
        vectors.each_with_index { |v, i| hash_table[v] = i }
        vectors.each { |v| hash_table[v] }
      end

      puts "Set operations (100 vectors): #{set_time.round(6)}s"
      puts "Hash table operations (100 vectors): #{hash_time.round(6)}s"

      expect(set_time).to be < 0.1
      expect(hash_time).to be < 0.1
    end
  end
end