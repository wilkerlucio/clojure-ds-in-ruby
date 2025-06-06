# frozen_string_literal: true

require "spec_helper"

RSpec.describe ClojureDsInRuby::PersistentVector do
  PersistentVector = ClojureDsInRuby::PersistentVector
  describe ".[]" do
    it "creates a vector with given elements" do
      vector = PersistentVector[1, 2, 3]
      expect(vector.to_a).to eq([1, 2, 3])
      expect(vector.size).to eq(3)
    end

    it "creates an empty vector when no elements given" do
      vector = PersistentVector[]
      expect(vector.empty?).to be true
      expect(vector.size).to eq(0)
    end
  end

  describe ".empty" do
    it "creates an empty vector" do
      vector = PersistentVector.empty
      expect(vector.empty?).to be true
      expect(vector.size).to eq(0)
    end
  end

  describe "#get" do
    let(:vector) { PersistentVector[1, 2, 3, 4, 5] }

    it "returns element at valid index" do
      expect(vector.get(0)).to eq(1)
      expect(vector.get(2)).to eq(3)
      expect(vector.get(4)).to eq(5)
    end

    it "returns nil for negative index" do
      expect(vector.get(-1)).to be_nil
    end

    it "returns nil for index beyond size" do
      expect(vector.get(5)).to be_nil
      expect(vector.get(100)).to be_nil
    end

    it "supports [] alias" do
      expect(vector[0]).to eq(1)
      expect(vector[2]).to eq(3)
    end
  end

  describe "#set" do
    let(:vector) { PersistentVector[1, 2, 3] }

    it "returns new vector with element updated" do
      new_vector = vector.set(1, 42)
      expect(new_vector.to_a).to eq([1, 42, 3])
      expect(vector.to_a).to eq([1, 2, 3]) # original unchanged
    end

    it "returns nil for invalid index" do
      expect(vector.set(-1, 42)).to be_nil
      expect(vector.set(3, 42)).to be_nil
    end

    it "supports assoc alias" do
      new_vector = vector.assoc(0, 99)
      expect(new_vector.to_a).to eq([99, 2, 3])
    end
  end

  describe "#push" do
    it "adds element to empty vector" do
      vector = PersistentVector.empty.push(1)
      expect(vector.to_a).to eq([1])
      expect(vector.size).to eq(1)
    end

    it "adds element to non-empty vector" do
      vector = PersistentVector[1, 2].push(3)
      expect(vector.to_a).to eq([1, 2, 3])
      expect(vector.size).to eq(3)
    end

    it "maintains immutability" do
      original = PersistentVector[1, 2]
      new_vector = original.push(3)
      expect(original.to_a).to eq([1, 2])
      expect(new_vector.to_a).to eq([1, 2, 3])
    end

    it "supports conj and << aliases" do
      vector = PersistentVector[1, 2]
      expect(vector.conj(3).to_a).to eq([1, 2, 3])
      expect(vector << 3).to eq(vector.push(3))
    end
  end

  describe "#pop" do
    it "removes last element" do
      vector = PersistentVector[1, 2, 3].pop
      expect(vector.to_a).to eq([1, 2])
      expect(vector.size).to eq(2)
    end

    it "returns empty vector when popping last element" do
      vector = PersistentVector[1].pop
      expect(vector.empty?).to be true
      expect(vector.size).to eq(0)
    end

    it "returns self when popping empty vector" do
      empty = PersistentVector.empty
      expect(empty.pop).to eq(empty)
    end

    it "maintains immutability" do
      original = PersistentVector[1, 2, 3]
      new_vector = original.pop
      expect(original.to_a).to eq([1, 2, 3])
      expect(new_vector.to_a).to eq([1, 2])
    end
  end

  describe "#concat" do
    it "concatenates with another vector" do
      v1 = PersistentVector[1, 2]
      v2 = PersistentVector[3, 4]
      result = v1.concat(v2)
      expect(result.to_a).to eq([1, 2, 3, 4])
    end

    it "concatenates with array" do
      vector = PersistentVector[1, 2]
      result = vector.concat([3, 4])
      expect(result.to_a).to eq([1, 2, 3, 4])
    end

    it "returns self when concatenating empty" do
      vector = PersistentVector[1, 2]
      expect(vector.concat([])).to eq(vector)
    end

    it "supports + alias" do
      v1 = PersistentVector[1, 2]
      v2 = PersistentVector[3, 4]
      expect(v1 + v2).to eq(v1.concat(v2))
    end
  end

  describe "#each" do
    it "iterates over all elements" do
      vector = PersistentVector[1, 2, 3]
      result = []
      vector.each { |x| result << x }
      expect(result).to eq([1, 2, 3])
    end

    it "returns enumerator when no block given" do
      vector = PersistentVector[1, 2, 3]
      enumerator = vector.each
      expect(enumerator).to be_a(Enumerator)
      expect(enumerator.to_a).to eq([1, 2, 3])
    end
  end

  describe "#==" do
    it "returns true for equivalent vectors" do
      v1 = PersistentVector[1, 2, 3]
      v2 = PersistentVector[1, 2, 3]
      expect(v1).to eq(v2)
    end

    it "returns false for different vectors" do
      v1 = PersistentVector[1, 2, 3]
      v2 = PersistentVector[1, 2, 4]
      expect(v1).not_to eq(v2)
    end

    it "returns false for different sizes" do
      v1 = PersistentVector[1, 2]
      v2 = PersistentVector[1, 2, 3]
      expect(v1).not_to eq(v2)
    end

    it "returns false for non-vector objects" do
      vector = PersistentVector[1, 2, 3]
      expect(vector).not_to eq([1, 2, 3])
      expect(vector).not_to eq("hello")
    end
  end

  describe "large vector operations" do
    it "handles vectors larger than branch factor" do
      large_vector = (1..100).reduce(PersistentVector.empty) { |v, i| v.push(i) }
      expect(large_vector.size).to eq(100)
      expect(large_vector.get(50)).to eq(51)
      expect(large_vector.get(99)).to eq(100)
    end

    it "maintains performance with deep trees" do
      large_vector = (1..1000).reduce(PersistentVector.empty) { |v, i| v.push(i) }
      expect(large_vector.size).to eq(1000)
      expect(large_vector.get(500)).to eq(501)
      expect(large_vector.get(999)).to eq(1000)
    end

    it "supports updates in large vectors" do
      large_vector = (1..100).reduce(PersistentVector.empty) { |v, i| v.push(i) }
      updated = large_vector.set(50, 999)
      expect(updated.get(50)).to eq(999)
      expect(large_vector.get(50)).to eq(51) # original unchanged
    end
  end

  describe "structural sharing" do
    it "shares structure between vectors" do
      original = (1..50).reduce(PersistentVector.empty) { |v, i| v.push(i) }
      modified = original.push(51)

      # Both vectors should share most of their structure
      # We can't easily test this directly, but we can verify behavior
      expect(original.size).to eq(50)
      expect(modified.size).to eq(51)
      expect(modified.get(49)).to eq(50)
      expect(modified.get(50)).to eq(51)
    end

    it "maintains independence after structural sharing" do
      base = (1..10).reduce(PersistentVector.empty) { |v, i| v.push(i) }
      branch1 = base.push(11).push(12)
      branch2 = base.push(21).push(22)

      expect(base.size).to eq(10)
      expect(branch1.to_a).to eq((1..12).to_a)
      expect(branch2.to_a).to eq([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 21, 22])
    end
  end

  describe "edge cases" do
    it "handles nil values" do
      vector = PersistentVector[1, nil, 3]
      expect(vector.get(1)).to be_nil
      expect(vector.size).to eq(3)
    end

    it "handles mixed types" do
      vector = PersistentVector[1, "hello", :symbol, [1, 2]]
      expect(vector.get(0)).to eq(1)
      expect(vector.get(1)).to eq("hello")
      expect(vector.get(2)).to eq(:symbol)
      expect(vector.get(3)).to eq([1, 2])
    end

    it "handles empty operations gracefully" do
      empty = PersistentVector.empty
      expect(empty.get(0)).to be_nil
      expect(empty.set(0, 1)).to be_nil
      expect(empty.pop).to eq(empty)
    end
  end
end