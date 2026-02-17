# frozen_string_literal: true

RSpec.describe Promptmenot::Pattern do
  subject(:pattern) do
    described_class.new(
      name: :test_pattern,
      category: :test,
      regex: /test\s+injection/i,
      sensitivity: :medium,
      confidence: :high
    )
  end

  describe "#initialize" do
    it "sets attributes" do
      expect(pattern.name).to eq(:test_pattern)
      expect(pattern.category).to eq(:test)
      expect(pattern.sensitivity).to eq(:medium)
      expect(pattern.confidence).to eq(:high)
    end

    it "converts name to symbol" do
      p = described_class.new(name: "string_name", category: :test, regex: /x/)
      expect(p.name).to eq(:string_name)
    end

    it "raises on invalid sensitivity" do
      expect do
        described_class.new(name: :x, category: :x, regex: /x/, sensitivity: :invalid)
      end.to raise_error(Promptmenot::PatternError, /Invalid sensitivity/)
    end

    it "raises on invalid confidence" do
      expect do
        described_class.new(name: :x, category: :x, regex: /x/, confidence: :invalid)
      end.to raise_error(Promptmenot::PatternError, /Invalid confidence/)
    end
  end

  describe "#active_at?" do
    context "with :low sensitivity pattern" do
      let(:low_pattern) { described_class.new(name: :x, category: :x, regex: /x/, sensitivity: :low) }

      it "is active at all levels" do
        %i[low medium high paranoid].each do |level|
          expect(low_pattern.active_at?(level)).to be true
        end
      end
    end

    context "with :medium sensitivity pattern" do
      it "is not active at :low" do
        expect(pattern.active_at?(:low)).to be false
      end

      it "is active at :medium and above" do
        %i[medium high paranoid].each do |level|
          expect(pattern.active_at?(level)).to be true
        end
      end
    end

    context "with :paranoid sensitivity pattern" do
      let(:paranoid_pattern) { described_class.new(name: :x, category: :x, regex: /x/, sensitivity: :paranoid) }

      it "is only active at :paranoid" do
        %i[low medium high].each do |level|
          expect(paranoid_pattern.active_at?(level)).to be false
        end
        expect(paranoid_pattern.active_at?(:paranoid)).to be true
      end
    end
  end

  describe "#match" do
    it "returns matches for matching text" do
      matches = pattern.match("this is a test injection attempt")
      expect(matches.size).to eq(1)
      expect(matches.first.matched_text).to eq("test injection")
    end

    it "returns empty array for non-matching text" do
      matches = pattern.match("completely safe text")
      expect(matches).to be_empty
    end

    it "returns multiple matches" do
      multi_pattern = described_class.new(name: :x, category: :x, regex: /bad/i)
      matches = multi_pattern.match("bad text with bad content")
      expect(matches.size).to eq(2)
    end

    it "handles nil text" do
      expect(pattern.match(nil)).to be_empty
    end
  end

  describe "#==" do
    it "equals pattern with same name and category" do
      other = described_class.new(name: :test_pattern, category: :test, regex: /different/)
      expect(pattern).to eq(other)
    end

    it "differs from pattern with different name" do
      other = described_class.new(name: :other, category: :test, regex: /test\s+injection/i)
      expect(pattern).not_to eq(other)
    end

    it "differs from non-Pattern objects" do
      expect(pattern).not_to eq("not a pattern")
    end
  end

  describe "#eql?" do
    it "behaves the same as ==" do
      other = described_class.new(name: :test_pattern, category: :test, regex: /different/)
      expect(pattern.eql?(other)).to be true
    end
  end

  describe "#hash" do
    it "returns same hash for equal patterns" do
      other = described_class.new(name: :test_pattern, category: :test, regex: /different/)
      expect(pattern.hash).to eq(other.hash)
    end

    it "can be used as hash key" do
      hash = { pattern => "value" }
      other = described_class.new(name: :test_pattern, category: :test, regex: /different/)
      expect(hash[other]).to eq("value")
    end

    it "works in a Set" do
      require "set"
      set = Set.new([pattern])
      other = described_class.new(name: :test_pattern, category: :test, regex: /different/)
      expect(set).to include(other)
      set.add(other)
      expect(set.size).to eq(1)
    end
  end
end
